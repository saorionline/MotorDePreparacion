# sample_*_raw — fixture de 5 transacciones

Datos **sintéticos**. Ninguna cifra, referencia ni cliente corresponde a nada real.

## Archivos

| Archivo | Lado | Líneas | Qué simula |
|---|---|---|---|
| `sample_transactions_raw.jsonl` | A | 6 | Webhooks de una pasarela de pagos, sobre 5 transacciones |
| `sample_payments_raw.jsonl` | B | 4 | Asientos del ERP de ventas |

6 líneas y 5 transacciones en el lado A: una es una **reentrega** del mismo webhook.
Esa asimetría es intencional.

## Supuestos fijados (los que el repo todavía no declara)

Estos supuestos **no salen de `README.md`, `featRules.md` ni `ENUNCIADO.md`** —
ahí no están. Se fijaron para poder generar el fixture. Si `ENUNCIADO.md` acaba
diciendo otra cosa, este archivo se regenera.

1. **Lado A** = pasarela de pagos. **Lado B** = ERP de ventas.
2. **Llave natural de cruce**: `data.order_ref` (A) ↔ `document_ref` (B).
3. **Moneda única**: `USD`. Sin FX en esta muestra.
4. **Dinero en enteros, en centavos.** Rango del enunciado 1–10 USD → 100–1000.
   No aparece ningún `float` en el archivo.
5. **Comisión de la pasarela**: 2,9 % + 30 ¢, redondeada a centavo entero.
   Invariante: `amount_gross_cents - fee_cents = amount_net_cents`.
6. **Zonas horarias**: el lado A trae timestamps **UTC** (sufijo `Z`).
   El lado B trae **fechas locales de `America/Bogota` (UTC−5), sin zona horaria declarada.**
   Esta diferencia está puesta a propósito.
7. **Ventana de conciliación**: 2026-09-08 a 2026-09-12.

## Los 5 escenarios

| # | `order_ref` | Bruto | Escenario | Qué regla te obliga a escribir |
|---|---|---|---|---|
| 1 | ORD-1001 | 425 | Match exacto | La regla base: referencia igual + importe igual + misma fecha |
| 2 | ORD-1002 | 980 | El ERP registró el **neto** (922), no el bruto | Decidir qué lado es bruto y qué lado es neto antes de comparar |
| 3 | ORD-1003 | 610 | El asiento se posteó **2 días después** | Tolerancia en días, y saber que un desfase no es un error |
| 4 | ORD-1004 | 155 | **Huérfano de A**: no existe asiento en el ERP | Clasificación de excepciones y severidad por importe |
| 5 | ORD-1005 | 330 | Webhook **reentregado** (mismo `event_id`, distinto `delivered_at`) | Deduplicación por hash antes de cruzar, o contarás 660 |

### Trampas escondidas, a propósito

- **ORD-1005 y la zona horaria.** El pago ocurrió a las `2026-09-11T02:55:00Z`,
  que en Bogotá son las 21:55 del **10** de septiembre. El ERP lo postea el
  `2026-09-10`. Si comparas fechas sin convertir, verás un desfase de −1 día que
  no existe. No lo arregles con una tolerancia: arréglalo normalizando la zona.
- **El redondeo de la comisión.** ORD-1004: 155 × 2,9 % = 4,495 ¢. Redondeado da 4,
  no 5. Si tu Python recalcula la comisión con otra regla de redondeo, la
  invariante `bruto − comisión = neto` falla en esa fila y solo en esa.
- **Los `counterparty` coinciden entre lados.** Es más fácil de lo que será en
  producción. Tenlo presente cuando midas tu tasa de automatización.

## Lo que este fixture NO trae todavía

Cuando quieras subir el nivel, estos son los siguientes, en orden de dificultad:

- Huérfano del lado B (un asiento del ERP sin pago en la pasarela).
- Pago parcial: un `order_ref` cubierto por dos asientos.
- Payout agregado: un depósito que agrupa varias transacciones.
- Reembolso y nota de crédito (importe negativo, `direction` invertida).
- Segunda moneda, para forzar la conversión.

## Ejercicio: la salida esperada

Antes de escribir una sola línea de Python, **llena esta tabla a mano**. Es el
caso dorado contra el que vas a probar. Si no puedes llenarla, todavía no
entiendes la regla que vas a implementar.

| `order_ref` | ¿Empareja? | Regla que aplica | `diferencia_importe` | `diferencia_dias` | Clase de excepción |
|---|---|---|---|---|---|
| ORD-1001 | | | | | |
| ORD-1002 | | | | | |
| ORD-1003 | | | | | |
| ORD-1004 | | | | | |
| ORD-1005 | | | | | |

**Totales que tienen que cuadrar:**
transacciones distintas en A = ___ · asientos en B = ___ ·
emparejadas = ___ · en excepción = ___ · `emparejadas + excepción = A ∪ B`.
