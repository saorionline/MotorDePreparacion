# ENUNCIADO CANÓNICO

**v0.1 · adoptado el 13 sep 2026** · origen: *Ejercicio en Relevo* (PDF, 12 sep 2026)

Este documento gobierna cada ejercicio de la carpeta `ejercicios/`. Cuando un archivo y este enunciado discrepan, se corrige el archivo.

---

## DEFINICIÓN

Un ejercicio no es un archivo de código. Es un **contrato de datos** que declara tres cosas: sus **entradas**, sus **salidas esperadas** y sus **invariantes**.

El contrato vive en `contrato.json` y es legible por los cuatro lenguajes. Ningún lenguaje es dueño del contrato; los cuatro lo obedecen.

## ESTACIONES

Todo ejercicio se resuelve una vez y se recorre cuatro veces, en este orden:

| | Estación | Oficio |
|---|---|---|
| 1 | **emisión** | Resuelve el ejercicio en TypeScript y **emite** sus resultados como datos en disco. No imprime en consola. |
| 2 | **preparación** | Lee lo emitido. Limpia, valida contra el contrato, transforma. Si el contrato se rompe, **falla ruidosamente**. |
| 3 | **interrogación** | Lee lo preparado. Formula en SQL las preguntas que el código no responde por sí solo. |
| 4 | **representación** | Lee las respuestas. Las convierte en figura mediante una especificación declarativa. |

## REGLA DE FLUJO

Los datos viajan en **una sola dirección**, siempre por archivos en disco.

Ninguna estación importa el código de otra; sólo consume su salida.

Si dos estaciones contienen la misma lógica, una de las dos está de más. *Esto es una prohibición, no una advertencia.*

## REGLA DE VERDAD

`.ts` es fuente. `.js` es producto de compilación y no se versiona.

El `.md` no es fuente: es la **lectura humana** del contrato.

Cuando el `.md` y el contrato discrepan, gana el contrato — y el `.md` se corrige en el mismo commit.

## REGLA DE VECINDAD

Todo lo que pertenece a un ejercicio vive en **una sola carpeta**: su enunciado, su contrato y sus cuatro estaciones.

Queda prohibido separar la nota de su código en árboles distintos. *Ése fue el origen del desorden actual.*

> Convivencia con `learningBook/`: cada ejercicio lleva su `enunciado.md` breve (la lectura humana del contrato, obligatoria y vecina del código). El libro explicativo extendido vive en `learningBook/` y **apunta** al ejercicio; nunca declara verdades propias sobre entradas, salidas o invariantes.

## CRITERIO DE TERMINACIÓN

Un ejercicio está terminado cuando las cuatro estaciones corren con **un solo comando** y la figura final es explicable con el enunciado en la mano, sin abrir el código.

---

## PROCESADORES (decisiones adoptadas)

| Estación | Dependencias | Ejecutor |
|---|---|---|
| 1 · TypeScript | `package.json` + `tsconfig.json` | `tsx` |
| 2 · Python | `pyproject.toml` | `python` / `uv run` |
| 3 · SQL | ninguna — motor embebido | `duckdb` |
| 4 · Figura | spec `.json` | **Vega-Lite** |

- Dependencias: **una por lenguaje** (`package.json`, `pyproject.toml`). Inevitable.
- Tareas: **una sola puerta** — los `scripts` de npm invocan Python y SQL.
- Python es **estación**, no tercera respuesta.
- Motor SQL: **DuckDB** (lee CSV/JSON directo, un binario, cero servidor).
- Figura: **Vega-Lite** (la gráfica también se declara, no se programa).
