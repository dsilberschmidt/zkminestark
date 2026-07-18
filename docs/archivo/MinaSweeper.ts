/**
 * MINASWEEPER — zkApp para Mina Protocol (o1js v2.x)
 * =====================================================================
 * Buscaminas 30×16 / 99 minas donde la puntuación son CLICKS, no tiempo.
 * Cada seed tiene un tablero determinista, un récord on-chain y un pozo.
 * Entrar cuesta 1 MINA; batir el récord paga el 90% del pozo.
 *
 * ARQUITECTURA
 * ------------
 * 1. GameProgram (ZkProgram recursivo): el jugador prueba OFF-CHAIN que
 *    completó el tablero legalmente en N clicks, sin publicar sus jugadas.
 *    Un paso de recursión = un click.
 * 2. MinaSweeper (SmartContract): guarda la raíz de un MerkleMap
 *    seedKey → hoja {commitment, récord, pozo, titular}. Verifica la
 *    prueba del GameProgram y paga.
 *
 * DECISIONES DE DISEÑO (acordadas en el prototipo)
 * ------------------------------------------------
 * - Tableros deterministas por seed ⇒ NO hay recolocación de minas al
 *   primer click. La región inicial (vacía por construcción) se abre a
 *   0 clicks: forma parte del estado inicial probado en `start`.
 * - Las BANDERAS no existen on-chain. Insight: con el tablero como
 *   witness, un chord válido es simplemente "click en una celda
 *   revelada con adj>0 que revela todos sus vecinos no-mina". Las
 *   banderas son una mecánica de seguridad del cliente, no de soundness.
 * - Cooldown de derrota (15s, 1m, 1m, 1m, aviso, 24h): se aplica en
 *   cliente; on-chain la versión v2 limitará ENTRADAS por (jugador,
 *   seed) vía OffchainState (ver TODO al final), porque nadie va a
 *   reportar voluntariamente su propia derrota.
 *
 * REPRESENTACIÓN DEL TABLERO
 * --------------------------
 * 480 celdas → 2 Fields de 240 bits (bit i = 1 ⇔ mina en celda i).
 * commitment = Poseidon(f0, f1). La máscara de reveladas usa el mismo
 * empaquetado.
 *
 * ⚠️ PRESUPUESTO DE CONSTRAINTS (leer antes de compilar)
 * ------------------------------------------------------
 * El paso `click` desempaqueta 480 bits de tablero + 2×480 de máscaras
 * y hace chequeos de vecindad por celda. Estimación gruesa: puede
 * acercarse o superar el límite de filas de Kimchi (~2^16) por circuito.
 * Si compile() falla por tamaño, la estrategia es trocear el chequeo de
 * clausura en sub-pruebas de ~60-120 celdas encadenadas por recursión
 * (mismo esquema, publicInput extendido con un cursor). Está señalado
 * como TODO(chunking) donde corresponde.
 */

import {
  Field,
  Bool,
  UInt64,
  PublicKey,
  Poseidon,
  Provable,
  Struct,
  ZkProgram,
  SelfProof,
  SmartContract,
  state,
  State,
  method,
  MerkleMap,
  MerkleMapWitness,
  AccountUpdate,
} from 'o1js';

/* ================= constantes del juego ================= */
const W = 30;
const H = 16;
const N = W * H;          // 480 celdas
const MINES = 99;
const SAFE = N - MINES;   // 381 celdas a revelar
const HALF = 240;         // bits por Field (2 Fields cubren 480)
const ENTRY = UInt64.from(1_000_000_000n);      // 1 MINA en nanomina
const NO_RECORD = Field(0xffff);                // "sin récord" (> cualquier N de clicks posible)

/* vecinos precomputados (JS puro; el bucle es estático ⇒ circuito fijo) */
const NEIGHBORS: number[][] = [];
for (let i = 0; i < N; i++) {
  const x = i % W, y = (i / W) | 0, out: number[] = [];
  for (let dy = -1; dy <= 1; dy++)
    for (let dx = -1; dx <= 1; dx++) {
      if (!dx && !dy) continue;
      const nx = x + dx, ny = y + dy;
      if (nx >= 0 && nx < W && ny >= 0 && ny < H) out.push(ny * W + nx);
    }
  NEIGHBORS.push(out);
}

/* ================= tipos provables ================= */

/** Tablero como witness privado: 2 Fields de 240 bits de minas. */
class Board extends Struct({ f0: Field, f1: Field }) {
  commitment(): Field {
    return Poseidon.hash([this.f0, this.f1]);
  }
  /** 480 Bools, bit i = hay mina en la celda i. */
  bits(): Bool[] {
    return [...this.f0.toBits(HALF), ...this.f1.toBits(HALF)];
  }
}

/** Máscara de celdas reveladas, mismo empaquetado que Board. */
class Mask extends Struct({ f0: Field, f1: Field }) {
  bits(): Bool[] {
    return [...this.f0.toBits(HALF), ...this.f1.toBits(HALF)];
  }
  static fromBits(bits: Bool[]): Mask {
    return new Mask({
      f0: Field.fromBits(bits.slice(0, HALF)),
      f1: Field.fromBits(bits.slice(HALF)),
    });
  }
}

/** Estado público que viaja entre pasos recursivos. */
class GameState extends Struct({
  boardCommitment: Field,
  revealed: Mask,
  clicks: Field,
}) {}

/* ================= helpers de circuito ================= */

/** adj(i) = nº de minas vecinas de la celda i (suma de Bools). */
function adjCount(mines: Bool[], i: number): Field {
  let acc = Field(0);
  for (const n of NEIGHBORS[i]) acc = acc.add(mines[n].toField());
  return acc;
}

/**
 * Regla de clausura de un click (cubre reveal simple, flood-fill y chord):
 * cada celda NUEVA en la máscara debe cumplir al menos una:
 *   a) es la celda clickeada (y no estaba revelada, y no es mina), o
 *   b) es vecina de una celda revelada (en newMask) con adj = 0, o
 *   c) es vecina de la celda clickeada, ésta ya estaba revelada con
 *      adj > 0 (chord), y la nueva celda no es mina.
 * Además: newMask ⊇ oldMask y ninguna celda nueva es mina.
 * TODO(chunking): trocear este bucle si el circuito excede el límite.
 */
function assertValidClick(
  mines: Bool[],
  oldBits: Bool[],
  newBits: Bool[],
  clickIndex: Field
) {
  // ¿el click fue sobre celda ya revelada (chord) o sin revelar (reveal)?
  let clickedWasOpen = Bool(false);
  let clickedAdj = Field(0);
  for (let i = 0; i < N; i++) {
    const isClicked = clickIndex.equals(Field(i));
    clickedWasOpen = Provable.if(isClicked, oldBits[i], clickedWasOpen);
    clickedAdj = Provable.if(isClicked, adjCount(mines, i), clickedAdj);
  }
  const isChord = clickedWasOpen.and(clickedAdj.greaterThan(Field(0)));

  let revealedSomething = Bool(false);

  for (let i = 0; i < N; i++) {
    const wasOpen = oldBits[i];
    const isOpen = newBits[i];
    // monotonicidad: no se puede "des-revelar"
    wasOpen.and(isOpen.not()).assertFalse('mask must be monotone');

    const isNew = isOpen.and(wasOpen.not());
    // ninguna celda nueva es mina
    isNew.and(mines[i]).assertFalse('revealed a mine');

    // b) vecino de un cero revelado en newMask
    let nextToOpenZero = Bool(false);
    // c) vecino de la celda clickeada
    let nextToClick = Bool(false);
    for (const n of NEIGHBORS[i]) {
      const nOpenZero = newBits[n].and(adjCount(mines, n).equals(Field(0)));
      nextToOpenZero = nextToOpenZero.or(nOpenZero);
      nextToClick = nextToClick.or(clickIndex.equals(Field(n)));
    }
    const isClicked = clickIndex.equals(Field(i));
    const justified = isClicked
      .or(nextToOpenZero)
      .or(isChord.and(nextToClick));
    isNew.and(justified.not()).assertFalse('unjustified reveal');

    revealedSomething = revealedSomething.or(isNew);
  }
  // un click que no revela nada no puede contarse (ni probarse)
  revealedSomething.assertTrue('click revealed nothing');
}

/* ================= ZkProgram: la partida ================= */

const GameProgram = ZkProgram({
  name: 'minasweeper-game',
  publicOutput: GameState,

  methods: {
    /**
     * Estado inicial: la región vacía de la casilla de inicio del seed
     * abierta a 0 clicks ("como en Linux", pero determinista).
     * startMask la calcula el cliente (flood-fill JS) y aquí se
     * verifica con la MISMA regla de clausura usando startCell.
     */
    start: {
      privateInputs: [Board, Field, Mask],
      async method(board: Board, startCell: Field, startMask: Mask) {
        const mines = board.bits();
        const empty = new Mask({ f0: Field(0), f1: Field(0) });
        // la casilla de inicio debe ser un cero (garantizado por el generador)
        // y su región se justifica con la regla de clausura estándar:
        assertValidClick(mines, empty.bits(), startMask.bits(), startCell);
        return {
          publicOutput: new GameState({
            boardCommitment: board.commitment(),
            revealed: startMask,
            clicks: Field(0), // la apertura inicial es gratis
          }),
        };
      },
    },

    /** Un click = un paso recursivo. */
    click: {
      privateInputs: [SelfProof, Board, Field, Mask],
      async method(
        prev: SelfProof<undefined, GameState>,
        board: Board,
        clickIndex: Field,
        newMask: Mask
      ) {
        prev.verify();
        const st = prev.publicOutput;
        // el tablero witness debe ser el mismo comprometido
        board.commitment().assertEquals(st.boardCommitment);

        assertValidClick(
          board.bits(),
          st.revealed.bits(),
          newMask.bits(),
          clickIndex
        );

        return {
          publicOutput: new GameState({
            boardCommitment: st.boardCommitment,
            revealed: newMask,
            clicks: st.clicks.add(1),
          }),
        };
      },
    },

    /** Cierre: todas las celdas seguras reveladas. */
    finish: {
      privateInputs: [SelfProof, Board],
      async method(prev: SelfProof<undefined, GameState>, board: Board) {
        prev.verify();
        const st = prev.publicOutput;
        board.commitment().assertEquals(st.boardCommitment);

        const mines = board.bits();
        const open = st.revealed.bits();
        let openCount = Field(0);
        for (let i = 0; i < N; i++) {
          // exhaustividad: toda celda no-mina está revelada
          mines[i].not().and(open[i].not()).assertFalse('unrevealed safe cell');
          openCount = openCount.add(open[i].toField());
        }
        openCount.assertEquals(Field(SAFE));
        return { publicOutput: st };
      },
    },
  },
});

export class GameProof extends ZkProgram.Proof(GameProgram) {}

/* ================= hoja del registro de seeds ================= */

class SeedLeaf extends Struct({
  boardCommitment: Field,
  record: Field,        // clicks del récord (NO_RECORD si nadie completó)
  pot: UInt64,          // pozo en nanomina
  holder: PublicKey,    // titular del récord
}) {
  hash(): Field {
    return Poseidon.hash([
      this.boardCommitment,
      this.record,
      ...this.pot.toFields(),
      ...this.holder.toFields(),
    ]);
  }
}

/* ================= SmartContract ================= */

export class MinaSweeper extends SmartContract {
  /** raíz del MerkleMap seedKey → SeedLeaf.hash() */
  @state(Field) registryRoot = State<Field>();

  init() {
    super.init();
    this.registryRoot.set(new MerkleMap().getRoot());
  }

  /**
   * Publica un seed nuevo. seedKey = Poseidon(bytes del seed) calculado
   * off-chain. Quien registra aporta el pozo semilla inicial.
   * NOTA DE CONFIANZA: el registrador conoce el tablero. Para seeds
   * "oficiales" conviene generarlos con un procedimiento público
   * verificable (p.ej. commitment derivado de un VRF o del hash de un
   * bloque futuro) — TODO(v2).
   */
  @method async registerSeed(
    seedKey: Field,
    boardCommitment: Field,
    seedPot: UInt64,
    witness: MerkleMapWitness
  ) {
    const root = this.registryRoot.getAndRequireEquals();
    const [rootBefore, key] = witness.computeRootAndKey(Field(0)); // hoja vacía
    rootBefore.assertEquals(root, 'seed already exists');
    key.assertEquals(seedKey);

    // el registrador deposita el pozo semilla
    const payer = AccountUpdate.createSigned(this.sender.getAndRequireSignature());
    payer.send({ to: this.address, amount: seedPot });

    const leaf = new SeedLeaf({
      boardCommitment,
      record: NO_RECORD,
      pot: seedPot,
      holder: PublicKey.empty(),
    });
    const [rootAfter] = witness.computeRootAndKey(leaf.hash());
    this.registryRoot.set(rootAfter);
  }

  /**
   * Entrada: 1 MINA al pozo del seed. El cliente juega off-chain después.
   * TODO(v2, cooldown): limitar entradas por (jugador, seed) con
   * Experimental.OffchainState guardando lastEntrySlot y aplicando la
   * escalera acordada. La derrota en sí nunca llega on-chain.
   */
  @method async enter(seedKey: Field, leaf: SeedLeaf, witness: MerkleMapWitness) {
    const root = this.registryRoot.getAndRequireEquals();
    const [rootBefore, key] = witness.computeRootAndKey(leaf.hash());
    rootBefore.assertEquals(root, 'stale leaf');
    key.assertEquals(seedKey);

    const payer = AccountUpdate.createSigned(this.sender.getAndRequireSignature());
    payer.send({ to: this.address, amount: ENTRY });

    const updated = new SeedLeaf({
      boardCommitment: leaf.boardCommitment,
      record: leaf.record,
      pot: leaf.pot.add(ENTRY),
      holder: leaf.holder,
    });
    const [rootAfter] = witness.computeRootAndKey(updated.hash());
    this.registryRoot.set(rootAfter);
  }

  /**
   * Reclamo de récord: verifica la prueba de la partida completa y,
   * si clicks < récord, paga el 90% del pozo; el 10% queda de semilla.
   */
  @method async claimRecord(
    seedKey: Field,
    leaf: SeedLeaf,
    witness: MerkleMapWitness,
    proof: GameProof
  ) {
    proof.verify();
    const game = proof.publicOutput;

    const root = this.registryRoot.getAndRequireEquals();
    const [rootBefore, key] = witness.computeRootAndKey(leaf.hash());
    rootBefore.assertEquals(root, 'stale leaf');
    key.assertEquals(seedKey);

    // la partida corresponde al tablero de este seed
    game.boardCommitment.assertEquals(leaf.boardCommitment);
    // y baja el récord
    game.clicks.assertLessThan(leaf.record, 'record not beaten');

    const claimer = this.sender.getAndRequireSignature();
    // 90% al ganador, 10% queda de semilla
    const prize = leaf.pot.mul(9).div(10);
    this.send({ to: claimer, amount: prize });

    const updated = new SeedLeaf({
      boardCommitment: leaf.boardCommitment,
      record: game.clicks,
      pot: leaf.pot.sub(prize),
      holder: claimer,
    });
    const [rootAfter] = witness.computeRootAndKey(updated.hash());
    this.registryRoot.set(rootAfter);
  }
}

/*
 * PENDIENTES (v2)
 * ---------------
 * 1. TODO(chunking): medir con analyzeMethods() el tamaño real de
 *    `click`; si excede el límite, trocear assertValidClick en
 *    sub-pruebas recursivas por rangos de celdas.
 * 2. TODO(cooldown): OffchainState por (jugador, seed) con la escalera
 *    de entradas 15s/1m/1m/1m/24h aplicada sobre slots de red
 *    (this.network.globalSlotSinceGenesis).
 * 3. TODO(front-running): claimRecord es visible en el mempool; el
 *    proof no liga al claimer. Ligar la identidad: incluir
 *    Poseidon(claimerPubKey) en el publicOutput del GameProgram
 *    (añadir al GameState) para que nadie pueda robar una prueba ajena.
 *    ESTE PUNTO ES IMPORTANTE ANTES DE MAINNET.
 * 4. TODO(seeds sin azar): flag opcional en SeedLeaf "certificado
 *    resoluble sin adivinar" — a decisión del creador del seed, con
 *    ambos modos coexistiendo (solo cabeza / cabeza + azar).
 * 5. Concurrencia: dos entradas simultáneas al mismo seed invalidan
 *    mutuamente sus witnesses; considerar Actions/Reducer para colas.
 */
