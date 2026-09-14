# 01 · ESTACIÓN 2 · PREPARACIÓN
# Lee lo emitido (datos/crudo.json). Limpia, valida contra contrato.json, transforma.
# Si el contrato se rompe, falla ruidosamente (exit 1).
# Escribe datos/limpio.csv. Sólo stdlib: json + csv.

import csv
import json
import sys
from pathlib import Path

AQUI = Path(__file__).parent
MAX_SEGURO = 2**53 - 1


def romper(mensaje: str) -> None:
    print(f"\n*** CONTRATO ROTO ***\n{mensaje}\n", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    contrato_path = AQUI / "contrato.json"
    crudo_path = AQUI / "datos" / "crudo.json"

    if not crudo_path.exists():
        romper("No existe datos/crudo.json — corre primero la estación 1 (emisión).")

    contrato = json.loads(contrato_path.read_text(encoding="utf-8"))
    crudo = json.loads(crudo_path.read_text(encoding="utf-8"))

    esperados = {
        (c["id"], i + 1): int(str(v))
        for c in contrato["contratos"]
        for i, v in enumerate(c["salidas_esperadas"])
    }

    filas_limpias = []
    for fila in crudo["filas"]:
        clave = (fila["contrato"], fila["caso"])

        # Validación 1: cada fila emitida corresponde a un caso del contrato
        if clave not in esperados:
            romper(f"Fila {clave} no existe en el contrato.")

        entrada = fila["entrada"]
        resultado = int(fila["resultado"])

        # Validación 2: salida esperada
        if resultado != esperados[clave]:
            romper(
                f"{fila['contrato']} caso {fila['caso']}: "
                f"esperado {esperados[clave]}, emitido {resultado}."
            )

        # Validación 3: exactitud — recomputamos con enteros de Python (precisión arbitraria)
        if resultado != sum(entrada):
            romper(
                f"{fila['contrato']} caso {fila['caso']}: la emisión perdió precisión "
                f"({resultado} != {sum(entrada)}). ¿Float64 en vez de BigInt?"
            )

        # Validación 4: invariante suma >= max para no negativos
        if any(x < 0 for x in entrada):
            romper(f"{fila['contrato']} caso {fila['caso']}: entrada con negativos.")
        if resultado < max(entrada):
            romper(f"{fila['contrato']} caso {fila['caso']}: suma < máximo. Imposible.")

        # Validación 5: rango-seguro no debe exceder 2^53 - 1
        if fila["contrato"] == "rango-seguro" and resultado > MAX_SEGURO:
            romper(f"rango-seguro caso {fila['caso']}: la suma excede 2^53-1.")

        # Validación 6: la bandera emitida dice la verdad
        if fila["excede_2_53"] != (resultado > MAX_SEGURO):
            romper(f"{fila['contrato']} caso {fila['caso']}: bandera excede_2_53 miente.")

        filas_limpias.append(
            {
                "contrato": fila["contrato"],
                "caso": fila["caso"],
                "n": fila["n"],
                "maximo": fila["maximo"],
                "suma": resultado,
                "excede_2_53": int(fila["excede_2_53"]),
            }
        )

    destino = AQUI / "datos" / "limpio.csv"
    with destino.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(filas_limpias[0].keys()))
        writer.writeheader()
        writer.writerows(filas_limpias)

    print(f"preparación OK · {len(filas_limpias)} filas validadas → {destino.name}")


if __name__ == "__main__":
    main()
