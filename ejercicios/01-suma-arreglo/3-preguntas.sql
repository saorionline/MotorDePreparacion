-- 01 · ESTACIÓN 3 · INTERROGACIÓN
-- Lee lo preparado (datos/limpio.csv). Formula las preguntas que el código
-- no responde por sí solo. Escribe datos/respuestas.csv.
-- Ejecutar desde la raíz del repo:  duckdb -c ".read ejercicios/01-suma-arreglo/3-preguntas.sql"

COPY (
    SELECT
        contrato,
        COUNT(*)                                  AS casos,
        SUM(n)                                    AS elementos_totales,
        MAX(suma)                                 AS suma_maxima,
        ROUND(AVG(suma), 2)                       AS suma_promedio,
        SUM(excede_2_53)                          AS casos_que_exceden_2_53,
        -- ¿Cuánto amplifica la agregación? razón suma/máximo:
        ROUND(AVG(suma * 1.0 / maximo), 3)        AS razon_suma_sobre_maximo
    FROM read_csv_auto('ejercicios/01-suma-arreglo/datos/limpio.csv')
    GROUP BY contrato
    ORDER BY contrato
) TO 'ejercicios/01-suma-arreglo/datos/respuestas.csv' (HEADER);
