# 01 · Suma de arreglo

**Lectura humana del contrato.** La fuente es `contrato.json`; si este texto discrepa, gana el contrato.

## Qué resuelve

Tomar un arreglo de enteros no negativos y reducirlo a un solo valor: su suma. Es el ejercicio de agregación clásico (HackerRank: *Simple Array Sum* y *A Very Big Sum*).

Bajo el enunciado canónico dejan de ser dos ejercicios: son **un ejercicio con dos contratos** —

- `rango-seguro`: la suma cabe por debajo de 2⁵³−1 y `number` alcanza.
- `rango-grande`: la suma puede exceder 2⁵³−1 y la emisión **debe usar `BigInt`**.

La diferencia que HackerRank finge en el código, aquí vive donde de verdad está: en los datos. Es la estación 2 (preparación, Python) la que valida cuál contrato se rompe.

> Esto resuelve la discrepancia histórica: `Big Sum.md` declaraba `BigInt` y `Bigsum.ts` nunca lo implementó. Ahora el contrato lo exige y la emisión lo cumple.

## El relevo

```
contrato.json → 1-emision.ts → datos/crudo.json → 2-preparacion.py → datos/limpio.csv
             → 3-preguntas.sql → datos/respuestas.csv → 4-figura.json → figura
```

Un solo comando: `npm run 01:todo` (desde la raíz del repo).

## Libro

Capítulos extendidos en `learningBook/`: *Exercise 1 HackerRank*, *Lista de Ejercicios/Big Sum*, *Lista de Ejercicios/Simple Sum y Compare Triplets*, *Resumen §1*.
