# Estación 2 — Preparación en Python

> Plan de implementación. **Propuesta, pendiente de aprobación** según el
> *Agent Pre-Implementation Protocol* de `.claudeRules/featRules.md`.
> Ninguna línea de este documento es código a copiar: son contratos, invariantes
> y criterios de aceptación. El código lo escribe Sao.

---

## 1. El problema, en una frase

Dos archivos crudos que no se parecen en nada tienen que convertirse en **una
tabla con una fila por transacción**, donde cada fila sepa si cuadra, cuánto se
descuadra y por qué.

Todo lo difícil de la conciliación está en esa frase. El cruce en sí es una
línea; lo que cuesta es que los dos lados sean comparables antes de cruzarlos.

---

## 2. Contrato de la estación

| | |
|---|---|
| **Entrada A** | `data/raw/sample_transactions_raw.jsonl` — pasarela, 6 líneas, 5 transacciones |
| **Entrada B** | `data/raw/sample_payments_raw.jsonl` — ERP, 4 asientos |
| **Salida** | `data/processed/transactions_clean.csv` |
| **Grano de salida** | 1 fila por `transaction_id`. PK única, sin excepciones |
| **Declaración del contrato** | `contrato.json` — **todavía no existe, es tu primer entregable** |

### Decisiones ya cerradas

1. Dinero en **enteros, en centavos**. Toda columna monetaria termina en `_cents`.
   Un `float` en cualquier punto del flujo es un defecto, no un detalle.
2. `expected_amount_cents` = **bruto de la pasarela**. `received_amount_cents` = **importe del ERP**.
   `difference_amount_cents = expected - received`. El signo importa y hay que documentarlo.
3. Columnas y archivos de datos en `snake_case`. Módulos `.py` en `camelCase` según `featRules`.

### Columnas de salida

Salen del ENUNCIADO. Tú decides el orden y si alguna sobra.

```
transaction_id, source_system, destination_system, integration_type, api_status,
currency, expected_amount_cents, received_amount_cents, difference_amount_cents,
created_at, detected_at, resolved_at,
reconciliation_status, exception_reason, priority,
automation_flag, automation_tool
```

---

## 3. Los seis pasos

Cada paso es una función pura, testeable sola. **No escribas el script entero de
una y luego depures**: escribe el paso 1, pruébalo con el fixture, y solo entonces
pasa al 2.

### Paso 1 — Cargar

*Entrada:* una ruta. *Salida:* lista de dicts.

JSONL es **una línea = un JSON**. `json.load()` sobre el archivo completo falla;
necesitas `json.loads()` línea a línea. Si una línea no parsea, no la saltes en
silencio: reporta el número de línea por `stderr` y termina con código 1.

> **Invariante:** líneas leídas = líneas del archivo. Si no, morir.

### Paso 2 — Validar contra el contrato

*Entrada:* filas + `contrato.json`. *Salida:* nada, o muerte ruidosa.

Antes de tocar un dato, comprueba que está lo que dijiste que iba a estar:
campos obligatorios presentes, tipos correctos, moneda dentro del conjunto
permitido, importes enteros y no negativos, fechas parseables.

> **Invariante clave:** `amount_gross_cents - fee_cents == amount_net_cents`, en
> todas las filas del lado A.
>
> Esta es la que te va a morder. ORD-1004: 155 × 2,9 % = 4,495 ¢. El fixture
> guarda 4. Si tú recalculas la comisión con otra regla de redondeo, esta
> invariante falla **en esa fila y solo en esa**. Cuando pase, la pregunta
> correcta no es "¿cómo lo silencio?" sino "¿quién tiene razón, el fixture o mi
> redondeo, y cómo lo decido?".

### Paso 3 — Deduplicar el lado A

*Entrada:* 6 filas. *Salida:* 5 filas + un contador de cuántas quitaste.

ORD-1005 llega dos veces: mismo `event_id`, mismo `charge_id`, mismo importe,
distinto `delivered_at`. Es una reentrega de webhook, no dos pagos.

Dos preguntas que tienes que contestar por escrito antes de codificar:

- ¿Deduplicas por `event_id`, o por hash del bloque `data`? ¿Qué pasa si la
  pasarela reenvía el mismo evento con un campo corregido?
- De las dos copias, ¿cuál te quedas? ¿La primera que llegó o la última?

> **Este paso va antes del cruce, siempre.** Si deduplicas después, ORD-1005 ya
> se cruzó dos veces contra el mismo asiento y tu diferencia es −330 en vez de 0.

### Paso 4 — Normalizar cada lado al formato canónico

*Entrada:* filas crudas de un lado. *Salida:* filas canónicas.

Dos funciones separadas, una por lado. No intentes una función genérica con
`if source == ...`: el día que entre el extracto bancario, esa función se vuelve
inmantenible.

Aquí resuelves tres cosas:

**Aplanar.** El lado A viene anidado (`data.order_ref`). El lado B es plano.

**Fechas.** El lado A trae `created_at` en **UTC** con sufijo `Z`. El lado B trae
`posting_date` como **fecha local de `America/Bogota` (UTC−5), sin zona declarada**.

> ORD-1005 ocurrió a las `2026-09-11T02:55:00Z`, que en Bogotá son las 21:55 del
> **10**. El ERP lo postea el `2026-09-10`. Si comparas las cadenas tal cual, ves
> un desfase de −1 día que no existe.
>
> No lo tapes con una tolerancia de ±1 día: eso esconde el bug y de paso te
> silencia desfases reales. Decide **una zona horaria de negocio**, declárala en
> `contrato.json`, y convierte ambos lados a ella antes de comparar días.

**Importes.** Lado A: `amount_gross_cents` → `expected_amount_cents`.
Lado B: `amount_cents` → `received_amount_cents`.

> Y aquí está ORD-1002. La pasarela dice bruto 980. El ERP registró 922. La
> diferencia es 58, que es **exactamente** `fee_cents`. Contabilidad registró el
> neto donde debía ir el bruto.
>
> Decisión tuya, y hay que argumentarla: ¿normalizas el lado B sumándole la
> comisión para que sea comparable, o lo dejas como está y lo marcas como
> excepción? Las dos son defendibles. Lo que no es defendible es no darse cuenta.
> Pista de por dónde va el oficio: una diferencia que coincide al centavo con la
> comisión no es un descuadre, es una **firma** — un patrón que identifica la
> causa raíz. Y las firmas se detectan, se nombran y se reportan.

### Paso 5 — Cruzar los dos lados

*Entrada:* lado A canónico, lado B canónico. *Salida:* una lista unificada.

Llave: `order_ref` (A) ↔ `document_ref` (B).

Tiene que ser un **full outer join**: filas de A sin B, filas de B sin A, y las
que casan. Si usas pandas, `how="outer"`. Si lo haces con diccionarios, recuerda
recorrer las claves de B que no consumiste.

> **Invariante de conservación:** `filas de salida = |refs de A ∪ refs de B|`.
> Nada aparece dos veces, nada desaparece. Es la invariante más importante del
> proyecto y la más fácil de romber sin enterarse.

ORD-1004 no tiene contraparte: `received_amount_cents` queda **vacío, no cero**.
Un cero dice "llegaron 0 centavos"; un vacío dice "no sé". En un CSV son cosas
distintas y en las sumas también.

### Paso 6 — Clasificar

*Entrada:* fila unida. *Salida:* la misma fila con las banderas puestas.

De aquí salen `difference_amount_cents`, `reconciliation_status`,
`exception_reason`, `priority`, `automation_flag`.

Antes de escribir un solo `if`, **escribe la tabla de decisión** en este mismo
documento: qué condición produce qué `reconciliation_status`, en qué orden se
evalúan, y cuál gana cuando dos aplican a la vez. Ese orden es una regla de
negocio, no un detalle de implementación.

Preguntas que la tabla tiene que contestar:

- ORD-1003 cuadra en importe pero el asiento llegó 2 días tarde. ¿`MATCHED`,
  o `PENDING`? ¿Cuál es tu tolerancia en días y de dónde sale ese número?
- `priority` va por monto: ¿qué umbrales? Con transacciones de 1 a 10 dólares,
  ¿un umbral fijo tiene sentido, o debería ser relativo?
- `automation_flag`: ¿qué excepción es segura de automatizar y cuál exige un humano?

---

## 4. Los cinco casos y qué prueban

| `transaction_id` | Prueba | Si tu código está mal, verás |
|---|---|---|
| ORD-1001 | El camino feliz | Si este falla, el bug es de carga o de tipos |
| ORD-1002 | Bruto vs neto | Diferencia de 58 sin explicación, o un `MATCHED` falso |
| ORD-1003 | Desfase real de 2 días | Un `MISMATCH` por fecha cuando el dinero cuadra |
| ORD-1004 | Huérfano de A | Un `0` donde debería haber vacío, y sumas que mienten |
| ORD-1005 | Duplicado + trampa de zona horaria | Diferencia de −330, o un desfase de −1 día inventado |

---

## 5. Definición de terminado

1. `python -m ...` corre y escribe `data/processed/transactions_clean.csv`.
2. El CSV tiene **5 filas** y una cabecera. Ni 4 ni 6.
3. Las tres invariantes se comprueban en código y hacen `sys.exit(1)` al romperse:
   conservación de filas, `bruto − comisión = neto`, y unicidad de `transaction_id`.
4. Existe al menos **una prueba que falla a propósito**: le metes un JSONL con una
   línea corrupta y compruebas que el proceso muere con código 1 y mensaje claro.
5. Correrlo dos veces seguidas produce un CSV byte a byte idéntico (idempotencia).
6. La tabla de decisión del paso 6 está escrita **en este documento**, no solo en el código.
7. Puedes explicar la trampa de ORD-1005 en voz alta sin mirar nada.

---

## 6. Tu orden de trabajo

1. Escribir `contrato.json`. Es el paso que más te va a costar y el que más te va a servir.
2. Llenar la tabla de salida esperada de `data/raw/sample_readme.md`, a mano.
3. Escribir la tabla de decisión del paso 6, aquí abajo.
4. Recién entonces, el paso 1 en Python.

### Tabla de decisión — la llenas tú

| Orden | Condición | `reconciliation_status` | `exception_reason` | `priority` | `automation_flag` |
|---|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
