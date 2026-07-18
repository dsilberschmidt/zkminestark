# zkminestark

**MinaSweeper** es un buscaminas on-chain donde gana quien piensa menos, no quien corre: la métrica es el número de clicks, no el tiempo. Tablero de 30×16 con 99 minas, temas visuales MINA/LINUX, y una economía de récords por seed con pozo compartido — pensado para ser tranquilizador, no ansiógeno.

La pieza técnica central es la generación diferida (lazy sampling): el tablero no existe hasta que se juega. Cada click sortea sobre la marcha, condicionado a los números ya revelados, vía VRF on-chain en Starknet/Dojo — así nadie, ni el propio jugador, puede precomputar de antemano la secuencia óptima. Es la salida a la falla que mataría cualquier buscaminas con premio en cripto: layouts públicos y deterministas que un bot resuelve el día uno.

## Estado actual

- ✅ Prototipo jugable (`client/minasweeper.html`): tablero, clicks, cooldowns de derrota, economía simulada, temas visuales.
- ✅ Diseño cerrado: las 7 incógnitas bloqueantes del proyecto están resueltas.
- ✅ Decisiones de arquitectura tomadas (lazy sampling + VRF, entrada gratuita + pozo patrocinado, temporadas, score relativo).
- 🔜 Port a Cairo/Dojo — Fase 0 (medición go/no-go de latencia VRF) es el próximo paso concreto.

## Documentación

- [`docs/ROADMAP-STARKNET.md`](docs/ROADMAP-STARKNET.md) — roadmap vigente, fases y decisiones de Dirección 001.
- [`docs/INCOGNITAS.md`](docs/INCOGNITAS.md) — las 7 incógnitas de diseño resueltas, con su razonamiento completo.

`docs/archivo/` conserva la rama determinista (Mina Protocol / o1js) como Plan B2 — revive solo si el proyecto pivota a tableros deterministas con entrada pagada.

## Licencia

MIT — ver [`LICENSE`](LICENSE).
