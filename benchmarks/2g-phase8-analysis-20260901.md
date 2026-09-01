# Phase 8 — Análisis de viabilidad CELL pipeline (2026-09-01)

Generado desde artefactos existentes sin re-run.  
Fuentes: `2g-phase8-fixtures-20260831.jsonl` (408 fixtures), `2g-phase8-snforge-combined-20260831.log`, `2g-phase8-snforge-s2-combined-20260901.log`.

---

## 1. CELL individuales — estadísticas globales

**Total medidos: 408/408 (100 % coverage, 0 missing)**

| Estadístico | Gas (L2 Sierra) |
|-------------|----------------:|
| min         |       9,533,936 |
| mean        |     637,504,030 |
| p50         |     143,358,980 |
| p90         |   1,131,196,752 |
| p95         |   5,547,600,721 |
| p99         |   6,164,853,528 |
| max         |   6,267,768,345 |

> **Distribución muy asimétrica**: mediana 143 M vs media 638 M. La mayoría de CELLs son baratos; la cola larga la generan únicamente f13, f14 y f15.

### Distribución por bucket (gate Starknet = 1.1 B L2 gas)

| Bucket       | Count | % |
|:-------------|------:|--:|
| < 750 M      |   331 | 81.1 % |
| 750 M – 900 M |    18 |  4.4 % |
| 900 M – 1.1 B |    14 |  3.4 % |
| **> 1.1 B**  |   **45** | **11.0 %** |

45 CELLs (11 %) exceden el gate de 1.1 B. Todos pertenecen a sólo 4 floods: f08, f13, f14, f15.

---

## 2. Todos los CELL > 1.1 B (45 total)

> Columnas: `flood | step | gas (B) | vars | constr | max_width | n_sp | sp_sizes/widths | n_ord | outcome`

### f15 = C04_044 (24 CELLs, todos >1.1B — flood patológico)

| step | gas (B) | vars | constr | w | n_sp | sp sizes/widths | n_ord | outcome |
|-----:|--------:|-----:|-------:|--:|-----:|:----------------|------:|:--------|
|  s001 | 6.268 | 181 | 102 | 0 | 0 | — | 6 | clue=0 |
|  s006 | 6.264 | 182 | 104 | 0 | 0 | — | 6 | clue=0 |
|  s007 | 6.209 | 187 | 105 | 4 | 1 | 5/4 | 6 | clue=0 |
|  s011 | 6.178 | 185 | 107 | 1 | 1 | 2/1 | 6 | clue=1 |
|  s008 | 6.165 | 188 | 106 | 4 | 1 | 6/4 | 6 | clue=0 |
|  s003 | 6.105 | 186 | 104 | 4 | 1 | 5/4 | 6 | clue=0 |
|  s009 | 6.105 | 188 | 107 | 4 | 1 | 6/4 | 6 | clue=0 |
|  s012 | 6.070 | 188 | 108 | 3 | 1 | 5/3 | 6 | clue=0 |
|  s002 | 6.067 | 186 | 103 | 4 | 1 | 5/4 | 6 | clue=0 |
|  s021 | 6.057 | 185 | 113 | 2 | 1 | 6/2 | 6 | clue=0 |
|  s022 | 6.037 | 188 | 114 | 4 | 1 | 9/4 | 6 | clue=1 |
|  s013 | 6.037 | 188 | 109 | 7 | 2 | 5/3+51/7 | 5 | clue=1 |
|  s016 | 6.002 | 185 | 110 | 2 | 1 | 4/2 | 6 | clue=1 |
|  s017 | 5.895 | 188 | 111 | 4 | 1 | 7/4 | 6 | clue=0 |
|  s019 | 5.891 | 189 | 113 | 7 | 1 | 57/7 | 5 | clue=0 |
|  s018 | 5.812 | 188 | 112 | 7 | 2 | 7/4+49/7 | 5 | clue=0 |
|  s014 | 5.788 | 189 | 110 | 7 | 1 | 57/7 | 5 | clue=0 |
|  s023 | 5.775 | 188 | 115 | 7 | 2 | 9/4+47/7 | 5 | clue=2 |
|  s024 | 5.774 | 189 | 116 | 7 | 1 | 57/7 | 5 | clue=2 |
|  s015 | 5.565 | 189 | 111 | 7 | 1 | 57/7 | 5 | clue=1 |
|  s010 | 5.548 | 189 | 108 | 7 | 2 | 7/4+50/7 | 5 | clue=1 |
|  s020 | 5.546 | 189 | 114 | 7 | 1 | 57/7 | 5 | clue=0 |
|  s005 | 5.517 | 187 | 106 | 7 | 1 | 55/7 | 5 | clue=1 |
|  s004 | 5.513 | 187 | 105 | 7 | 2 | 49/7+6/4 | 5 | clue=2 |

### f14 = C04_035 (12 CELLs > 1.1B de 18 totales)

| step | gas (B) | vars | constr | w | n_sp | sp sizes/widths | n_ord | outcome |
|-----:|--------:|-----:|-------:|--:|-----:|:----------------|------:|:--------|
| s018 | 2.740 | 173 |  95 | 7 | 1 | 90/7 | 6 | clue=0 |
| s016 | 1.853 | 171 |  93 | 7 | 1 | 88/7 | 6 | clue=0 |
| s017 | 1.837 | 172 |  94 | 7 | 1 | 89/7 | 6 | clue=1 |
| s007 | 1.430 | 172 |  89 | 7 | 1 | 89/7 | 6 | clue=0 |
| s008 | 1.376 | 172 |  90 | 7 | 1 | 89/7 | 6 | clue=0 |
| s006 | 1.359 | 171 |  88 | 7 | 2 | 52/7+36/7 | 6 | clue=0 |
| s005 | 1.301 | 170 |  87 | 7 | 1 | 51/7 | 7 | clue=0 |
| s003 | 1.291 | 166 |  85 | 7 | 1 | 47/7 | 7 | clue=0 |
| s001 | 1.264 | 164 |  83 | 7 | 1 | 45/7 | 7 | clue=1 |
| s002 | 1.256 | 166 |  84 | 7 | 1 | 47/7 | 7 | clue=0 |
| s004 | 1.240 | 169 |  86 | 7 | 1 | 50/7 | 7 | clue=0 |
| s015 | 1.123 | 170 |  92 | 7 | 2 | 51/7+36/7 | 6 | clue=1 |

### f13 = C04_030 (8 CELLs > 1.1B de 11 totales)

| step | gas (B) | vars | constr | w | n_sp | sp sizes/widths | n_ord | outcome |
|-----:|--------:|-----:|-------:|--:|-----:|:----------------|------:|:--------|
| s008 | 1.233 | 143 | 76 | 7 | 1 | 39/7 | 6 | clue=0 |
| s007 | 1.160 | 142 | 75 | 7 | 1 | 38/7 | 6 | clue=0 |
| s006 | 1.155 | 139 | 74 | 7 | 1 | 35/7 | 6 | clue=0 |
| s011 | 1.152 | 143 | 78 | 7 | 1 | 39/7 | 6 | clue=1 |
| s003 | 1.132 | 134 | 71 | 7 | 1 | 30/7 | 6 | clue=1 |
| s005 | 1.131 | 138 | 73 | 7 | 1 | 34/7 | 6 | clue=0 |
| s010 | 1.106 | 142 | 77 | 7 | 1 | 38/7 | 6 | clue=1 |
| s009 | 1.105 | 141 | 76 | 7 | 1 | 37/7 | 6 | clue=1 |

### f08 = C03_036 (1 CELL > 1.1B de 40 totales)

| step | gas (B) | vars | constr | w | n_sp | sp sizes/widths | n_ord | outcome |
|-----:|--------:|-----:|-------:|--:|-----:|:----------------|------:|:--------|
| s003 | 1.104 | 158 | 77 | 7 | 2 | 46/7+8/7 | 5 | clue=0 |

> f08_s003 = 1.104 B es el único CELL de f08 que excede el gate (en 0.4 %).

---

### Confirmación: ¿el ~1.4B mencionado en PENDING era un CELL individual?

**Sí.** `f14_s007` = 1,430,253,780 L2 gas es una medición de CELL benchmark individual (un solo paso de flood-fill), directamente comparable con el gate de 1.1 B. No es gas acumulado, no es el combined test, no es una estimación.

---

## 3. Análisis por flood (22 floods)

| fl | flood_id | n | sum_gas(B) | mean(M) | med(M) | max(M) | first(M) | maxW | >1.1B |
|---:|:---------|--:|-----------:|--------:|-------:|-------:|---------:|-----:|------:|
|  1 | C01_029 | 38 | 10.78 | 283.6 | 250.5 |  571.1 | 431.0 | 5 |  0 |
|  2 | C02_004 | 10 |  1.24 | 124.0 | 135.3 |  155.4 |  93.3 | 6 |  0 |
|  3 | C02_025 | 10 |  3.07 | 306.9 | 306.6 |  399.1 | 277.2 | 6 |  0 |
|  4 | C03_000 |  9 |  0.12 |  12.8 |  13.7 |   16.0 |  13.7 | 3 |  0 |
|  5 | C03_009 | 17 |  2.38 | 139.8 | 141.9 |  165.8 | 138.8 | 7 |  0 |
|  6 | C03_012 | 16 |  2.21 | 138.2 | 132.5 |  163.5 | 159.9 | 6 |  0 |
|  7 | C03_027 | 36 | 19.11 | 530.9 | 518.1 |  622.5 | 606.6 | 4 |  0 |
|  8 | C03_036 | 40 | 31.41 | 785.3 | 756.9 | 1104.2 | 908.8 | 7 |  1 |
|  9 | C04_000 |  9 |  0.15 |  16.2 |  14.7 |   29.2 |  13.7 | 2 |  0 |
| 10 | C04_001 | 28 |  0.81 |  29.0 |  29.7 |   43.2 |  33.2 | 4 |  0 |
| 11 | C04_005 | 33 |  1.94 |  58.7 |  58.5 |   76.9 |  62.0 | 4 |  0 |
| 12 | C04_020 | 10 |  3.50 | 350.5 | 343.7 |  380.0 | 341.5 | 6 |  0 |
| 13 | C04_030 | 11 | 12.41 |1128.2 |1131.2 | 1232.6 |1076.1 | 7 |  8 |
| 14 | C04_035 | 18 | 24.43 |1357.0 |1264.1 | 2739.7 |1264.1 | 7 | 12 |
| 15 | C04_044 | 24 |142.19 |5924.4 |6037.3 | 6267.8 |6267.8 | 7 | 24 |
| 16 | P02_004 | 10 |  1.24 | 124.0 | 135.3 |  155.4 |  93.3 | 6 |  0 |
| 17 | P05_000 |  9 |  0.12 |  12.8 |  13.7 |   16.0 |  13.7 | 3 |  0 |
| 18 | P06_000 |  9 |  0.15 |  16.2 |  14.7 |   29.2 |  13.7 | 2 |  0 |
| 19 | P06_001 | 28 |  0.81 |  29.0 |  29.7 |   43.2 |  33.2 | 4 |  0 |
| 20 | P07_000 |  3 |  0.04 |  12.5 |  13.7 |   13.9 |  13.7 | 1 |  0 |
| 21 | P07_001 |  9 |  0.22 |  24.2 |  22.9 |   40.6 |  30.8 | 4 |  0 |
| 22 | P07_008 | 31 |  1.80 |  58.1 |  53.8 |   95.8 |  53.8 | 4 |  0 |

---

## 4. Distribución de gas total de flood (22 floods)

| Estadístico | Valor |
|-------------|------:|
| min         | 0.037 B |
| mean        | 11.82 B |
| p50         |  1.94 B |
| p75         | 10.78 B |
| p90         | 24.43 B |
| p95         | 31.41 B |
| max         | 142.2 B |

| Bucket     | Count | % |
|:-----------|------:|--:|
| < 1.1 B    |     8 | 36.4 % |
| 1.1–2.2 B  |     4 | 18.2 % |
| 2.2–3.3 B  |     3 | 13.6 % |
| 3.3–5.5 B  |     1 |  4.5 % |
| > 5.5 B    |     6 | 27.3 % |

**8/22 floods (36 %) caben completos en una sola tx de 1.1 B.**

Distribución de tx necesarias si todos los CELL individuales caben por tx:

| Budget/tx | 1 tx | 2 tx | 3 tx | 4 tx | >4 tx | Unsegmentable |
|:----------|-----:|-----:|-----:|-----:|------:|--------------:|
| 1.1 B     |    8 |    4 |    3 |    1 |     2 |             4 |
| 900 M     |    8 |    2 |    4 |    1 |     3 |             4 |
| 750 M     |    6 |    4 |    2 |    2 |     4 |             4 |

**4 floods son "unsegmentables" a cualquier budget si no se hace split intra-CELL** (f08, f13, f14, f15): tienen al menos un CELL individual que excede 1.1 B.

---

## 5. Segmentación flood-a-flood (greedy, orden secuencial de steps)

| fl | flood_id | n | @1.1B | @900M | @750M | nota |
|---:|:---------|--:|------:|------:|------:|:-----|
|  1 | C01_029 | 38 | 11 tx | 15 tx | 18 tx | |
|  2 | C02_004 | 10 |  2 tx |  2 tx |  2 tx | |
|  3 | C02_025 | 10 |  3 tx |  4 tx |  6 tx | |
|  4 | C03_000 |  9 |  1 tx |  1 tx |  1 tx | |
|  5 | C03_009 | 17 |  3 tx |  3 tx |  4 tx | |
|  6 | C03_012 | 16 |  3 tx |  3 tx |  4 tx | |
|  7 | C03_027 | 36 | 21 tx | 36 tx | 36 tx | |
|  8 | C03_036 | 40 | UNSEG | UNSEG | UNSEG | max_cell=1.104B — 1 CELL supera gate |
|  9 | C04_000 |  9 |  1 tx |  1 tx |  1 tx | |
| 10 | C04_001 | 28 |  1 tx |  1 tx |  2 tx | |
| 11 | C04_005 | 33 |  2 tx |  3 tx |  3 tx | |
| 12 | C04_020 | 10 |  4 tx |  5 tx |  5 tx | |
| 13 | C04_030 | 11 | UNSEG | UNSEG | UNSEG | max_cell=1.233B — 8/11 CELLs superan gate |
| 14 | C04_035 | 18 | UNSEG | UNSEG | UNSEG | max_cell=2.740B — 12/18 CELLs superan gate |
| 15 | C04_044 | 24 | UNSEG | UNSEG | UNSEG | max_cell=6.268B — TODOS 24 CELLs superan gate |
| 16 | P02_004 | 10 |  2 tx |  2 tx |  2 tx | |
| 17 | P05_000 |  9 |  1 tx |  1 tx |  1 tx | |
| 18 | P06_000 |  9 |  1 tx |  1 tx |  1 tx | |
| 19 | P06_001 | 28 |  1 tx |  1 tx |  2 tx | |
| 20 | P07_000 |  3 |  1 tx |  1 tx |  1 tx | |
| 21 | P07_001 |  9 |  1 tx |  1 tx |  1 tx | |
| 22 | P07_008 | 31 |  2 tx |  3 tx |  3 tx | |

> **Nota sobre C03_027 (f07)**: con budget @900M requiere 36 tx = 1 tx por CELL (ningún CELL supera 900M pero la suma de pares excede). Con @1.1B 21 tx. Es el flood más largo segmentable.

---

## 6. Combined vs suma individual

| flood | combined (medido) | suma individual | ratio | n_steps |
|:------|------------------:|----------------:|------:|--------:|
| f20 (P07_000, 3 steps) | 0.0373 B | 0.0374 B | 0.9992 | 3 |
| f06 (C03_012, 16 steps) | 2.2109 B | 2.2111 B | 0.9999 | 16 |
| f08 (C03_036, 40 steps) | — (no resultado) | 31.41 B | n/a | 40 |

**f08 combined no produjo resultado**: `snforge --max-n-steps 4294967295` = 4.29 B es el límite del test runner (pasos de ejecución de la VM local). La suma individual de f08 es ~31.4 B, 7× mayor. **Este límite NO es el gate Starknet de 1.1 B Sierra gas**: son métricas distintas. El gate de Starknet aplica por tx on-chain; el límite de snforge aplica por test local de una sola ejecución continua. La incapacidad de ejecutar el combined test no implica que los CELLs individuales sean inválidos — de hecho, cada CELL de f08 se verificó individualmente en exact_s1 con correctness completo.

Ratio f06 ≈ 1.0000: las mediciones individuales y combinadas son consistentes. El overhead de combinar CELLs en una función es despreciable (~0.01 %).

---

## 7. Predictores de gas alto

Correlaciones con gas L2 (n=408):

| Feature | r | mean @>1.1B (n=45) | mean @≤1.1B (n=363) |
|:--------|--:|-------------------:|--------------------:|
| total_constr | **+0.712** | 96.8 | 33.4 |
| total_vars   | **+0.679** | 173.4 | 58.8 |
| unc_oth      | **−0.687** | 154.6 | 364.4 |
| n_ord        | +0.330 | 5.8 | 3.1 |
| total_sp_size | +0.201 | 41.9 | 22.8 |
| max_w        | +0.216 | 5.8 | 3.9 |
| n_sp         | +0.066 | 1.1 | 1.0 |
| rm (remaining_mines) | ≈0 | 99.0 | 99.0 |

**Distribución de CELL >1.1B por max_width**:

| width | n CELL | n >1.1B | % |
|------:|-------:|--------:|--:|
| 0 |  49 |  2 |  4.1 % |
| 1 |  17 |  1 |  5.9 % |
| 2 |  15 |  2 | 13.3 % |
| 3 |  25 |  1 |  4.0 % |
| 4 | 144 |  7 |  4.9 % |
| 5 |  40 |  0 |  0.0 % |
| 6 |  36 |  0 |  0.0 % |
| **7** |  **82** | **32** | **39.0 %** |

**Observaciones descriptivas** (sin claims causales):

- **Width=7 es el predictor más discriminante**: 39 % de CELLs con max_width=7 superan el gate, vs <15 % en cualquier otro width.
- Los dos CELLs >1.1B con width=0 (f15_s001, f15_s006) no tienen special component pero tienen 6 ordinary components con vars totales 181–182 y unc_oth=129–135. El gas proviene del convolve_ordinary iterado más extract_outcomes.
- **total_vars y total_constr** (r≈0.70) son mejores predictores lineales globales que max_width porque capturan el tamaño total del problema, no sólo el de la special component.
- **unc_oth negativo** (r=−0.687): los CELLs >1.1B pertenecen todos al flood C04_044 (unc_oth≈114–135) o C04_035/C04_030 (unc_oth≈160–179), mientras que CELLs baratos tienen unc_oth>>300. Esto refleja que en tableros más avanzados (más minas resueltas) el problema combinatorio es más costoso.
- **n_sp no discrimina**: el promedio de special components es 1.1 para CELLs caros vs 1.0 para los baratos. Tener 2 special components no es indicativo por sí solo.
- **rm = 99 en todos**: el corpus Phase 8 corre con 99 minas fijas; no hay variación en este predictor.

---

## 8. Conclusiones

### A. ¿Todos los CELL individuales medidos entran en 1.1 B?

**No.** 45 de 408 (11 %) superan el gate de 1.1 B Sierra gas.

### B. ¿Cuántos y cuánto exceden?

- 1 CELL supera por <1 % (f08_s003: 1.104 B, +4 M sobre el gate)
- 8 CELLs de f13: entre 1.105 B y 1.233 B (+1–12 %)
- 12 CELLs de f14: entre 1.123 B y 2.740 B (+2–149 %)
- 24 CELLs de f15: entre 5.513 B y 6.268 B (+400–470 %)

Los outliers severos (f15) exceden el gate por 5–6×. No son casos límite: requieren reducción de complejidad algorítmica o batching intra-CELL.

### C. ¿Continuation entre CELLs basta para la mayoría de floods?

**Para 18/22 floods (82 %) sí**: todos sus CELLs individuales caben en 1.1 B, por lo que la segmentación entre CELLs es suficiente. Algunos requieren muchas tx (f01: 11 tx, f07: 21 tx), pero son segmentables.

### D. ¿Hay casos que requerirían continuation DENTRO del CELL?

**Sí, 4 floods** (f08 marginalmente, f13, f14, f15) contienen al menos un CELL individual que supera 1.1 B. Para estos casos, la continuation entre CELLs no resuelve el problema: habría que dividir el cómputo de un CELL en múltiples tx (continuation intra-CELL), lo que no existe en la arquitectura actual, o reducir el gas del CELL mediante optimizaciones algorítmicas (mejor ordering VE, memoización, estructuras más eficientes) o bien constrained VE parcial.

### E. ¿Flood-fill es principalmente problema de tx limit, gas total, o ambos?

**Ambos, con naturaleza distinta**:

- **Gas total**: incluso floods "normales" como f01 (10.78 B) o f07 (19.11 B) requieren 11–21 tx bajo 1.1 B. La suma de gas es el factor dominante para floods largos (38–40 CELLs).
- **Tx limit individual**: f08, f13, f14, f15 tienen CELLs que superan el gate unitario; ninguna segmentación entre CELLs los resuelve.
- **f15 (C04_044)** es un caso extremo: cada CELL individual usa 5–6 B, y hay 24 de ellos (suma 142 B). Requeriría ~130 tx si los CELLs individuales fueran reducibles al gate, lo que no es práctico.

### F. ¿Sigue siendo razonable mantener 30×16/99 en testnet con la arquitectura actual?

**Para 18/22 floods del corpus sí es razonable** (todos sus CELLs pasan el gate). El board 30×16/99 no es en sí el problema; lo es la combinación de un tablero altamente constrained con alta unc_oth en juego temprano.

Los 4 floods problemáticos corresponden todos a flood-fills en la historia C04, que tiene características geométricas particulares (componentes muy conectadas, width=7 VE). Un sistema de producción podría:
1. Detectar ex-ante si el VE width >6 y diferir a modo "seguro" (revelation parcial).
2. Limitar el depth de flood-fill en tableros con ≥6 ordinary components.
3. Aceptar que esos casos no son certificables on-chain con la arquitectura actual.

---

## 9. Artefactos generados / modificados en Phase 8

### git diff --stat HEAD

```
 contracts/zkmine_2g/src/bigint.cairo | 41 +++++++++++++++++++++++++++++++++
 contracts/zkmine_2g/src/cell.cairo   | 39 +++++++++++++++++++++++++++-----
 contracts/zkmine_2g/src/tests.cairo  |  3 +++
 docs/bitacora.md                     | 44 ++++++++++++++++++++++++++++++++++++
 4 files changed, 121 insertions(+), 6 deletions(-)
```

### git status --short (archivos nuevos no committeados)

```
?? benchmarks/2g-phase8-fixture-gen.log
?? benchmarks/2g-phase8-fixtures-20260831.jsonl
?? benchmarks/2g-phase8-snforge-combined-20260831.log
?? benchmarks/2g-phase8-snforge-s2-combined-20260901.log
?? benchmarks/2g-phase8-analysis-20260901.md          ← este archivo
?? contracts/zkmine_2g/src/tests/test_ve_phase8.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase8_combined.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase8_exact.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase8_exact_s1.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase8_exact_s2.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase8_s1.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase8_s2.cairo
?? scripts/gen_phase8_cairo_tests.py
?? scripts/gen_phase8_fixtures.py
?? scripts/run_phase8_sharded.sh
```

### Datos derivados vs medidos

| Dato | Fuente |
|:-----|:-------|
| 408 gas measurements | Medido (snforge, logs) |
| Estadísticas globales | Derivado de logs |
| fixture metadata (vars, constr, widths) | Medido (gen_phase8_fixtures.py) |
| Segmentación greedy | Derivado (greedy sobre datos medidos) |
| Correlaciones | Derivado descriptivo |
| combined f20/f06 | Medido (snforge combined shard) |
| combined f08 | No medido (excede runner limit) |
