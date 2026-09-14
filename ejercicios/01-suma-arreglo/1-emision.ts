// 01 · ESTACIÓN 1 · EMISIÓN
// Resuelve el ejercicio y emite sus resultados como datos en disco.
// No imprime en consola. Lee contrato.json; escribe datos/crudo.json.
// Lógica original: algoritmos.ts (simpleArraySum) y Mathematics/Bigsum.ts (aVeryBigSum),
// ahora con BigInt, como el contrato rango-grande exige.

import * as fs from "fs";
import * as path from "path";

const AQUI = __dirname;
const MAX_SEGURO = 9007199254740991n; // 2^53 - 1

interface Contrato {
  id: string;
  entradas: { casos: number[][] };
  salidas_esperadas: (number | string)[];
}

interface ContratoJson {
  ejercicio: string;
  contratos: Contrato[];
}

// La solución: una sola, exacta. BigInt cubre ambos contratos sin perder precisión.
function sumaArreglo(ar: number[]): bigint {
  return ar.reduce((acc, n) => acc + BigInt(n), 0n);
}

function emitir(): void {
  const contrato: ContratoJson = JSON.parse(
    fs.readFileSync(path.join(AQUI, "contrato.json"), "utf-8")
  );

  const filas = contrato.contratos.flatMap((c) =>
    c.entradas.casos.map((caso, i) => {
      const suma = sumaArreglo(caso);
      return {
        ejercicio: contrato.ejercicio,
        contrato: c.id,
        caso: i + 1,
        n: caso.length,
        entrada: caso,
        maximo: Math.max(...caso),
        resultado: suma.toString(), // BigInt viaja como string: exacto en JSON
        excede_2_53: suma > MAX_SEGURO,
        esperado: String(c.salidas_esperadas[i])
      };
    })
  );

  const salida = path.join(AQUI, "datos");
  fs.mkdirSync(salida, { recursive: true });
  fs.writeFileSync(
    path.join(salida, "crudo.json"),
    JSON.stringify({ emitido: new Date().toISOString(), filas }, null, 2)
  );
}

emitir();
