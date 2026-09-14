# migrar.ps1 — Migración física según ENUNCIADO.md e inventario del README
# Ejecutar desde la raíz del repo:   .\migrar.ps1
# Limpieza de compilados (paso destructivo, opcional):   .\migrar.ps1 -Limpiar
#
# Por qué existe: los movimientos/renombres los hace el sistema de archivos nativo;
# todo lo textual (contrato, estaciones, enunciados) ya fue creado por separado.

param([switch]$Limpiar)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# ── 1 · El libro: Algoritmos → learningBook ──────────────────────────────
if (Test-Path "Algoritmos") {
    Rename-Item -Path "Algoritmos" -NewName "learningBook"
    Write-Host "✔ Algoritmos → learningBook (notas y PNGs viajan juntos)"
} else {
    Write-Host "· learningBook ya existe, nada que renombrar"
}

# ── 2 · Carpetas de ejercicios ───────────────────────────────────────────
$ejercicios = @(
    "01-suma-arreglo", "02-compara-tripletas", "03-apreton-de-manos",
    "04-extraccion-maxima", "05-salto-del-caballo", "06-rotacion-izquierda",
    "07-triangulo-minimo", "08-escalera", "09-juego-del-ejercito"
)
foreach ($e in $ejercicios) {
    New-Item -ItemType Directory -Force -Path "ejercicios\$e" | Out-Null
}
Write-Host "✔ ejercicios/01..09 creados"

# ── 3 · Mathematics se fusiona con ejercicios (fuente .ts, fila por fila) ─
$movimientos = @{
    "algoritmos.ts"                                   = "ejercicios\01-suma-arreglo"
    "Mathematics\Bigsum.ts"                           = "ejercicios\01-suma-arreglo"
    "triplets.ts"                                     = "ejercicios\02-compara-tripletas"
    "Mathematics\Handshake.ts"                        = "ejercicios\03-apreton-de-manos"
    "Mathematics\MaximumDraw.ts"                      = "ejercicios\04-extraccion-maxima"
    "Mathematics\KnightsTour\knights_tour.ts"         = "ejercicios\05-salto-del-caballo"
    "Mathematics\More_Exercises\LeftArrayRotation.ts" = "ejercicios\06-rotacion-izquierda"
    "Mathematics\More_Exercises\LowestTriangle.ts"    = "ejercicios\07-triangulo-minimo"
    "Mathematics\More_Exercises\StaircaseNested.ts"   = "ejercicios\08-escalera"
    "Mathematics\TheArmyGame\theArmygame.ts"          = "ejercicios\09-juego-del-ejercito"
}
foreach ($origen in $movimientos.Keys) {
    if (Test-Path $origen) {
        Move-Item -Path $origen -Destination $movimientos[$origen]
        Write-Host "✔ $origen → $($movimientos[$origen])"
    }
}

# El README de Mathematics se conserva dentro del libro
if (Test-Path "Mathematics\README.md") {
    Move-Item "Mathematics\README.md" "learningBook\Mathematics-README.md"
    Write-Host "✔ Mathematics/README.md → learningBook/Mathematics-README.md"
}

# ── 4 · Limpieza (sólo con -Limpiar): los 10 .js compilados y carcasas ───
if ($Limpiar) {
    $js = @(
        "algoritmos.js", "triplets.js",
        "Mathematics\Bigsum.js", "Mathematics\Handshake.js", "Mathematics\MaximumDraw.js",
        "Mathematics\KnightsTour\knights_tour.js",
        "Mathematics\More_Exercises\LeftArrayRotation.js",
        "Mathematics\More_Exercises\LowestTriangle.js",
        "Mathematics\More_Exercises\StaircaseNested.js",
        "Mathematics\TheArmyGame\theArmygame.js"
    )
    foreach ($f in $js) { if (Test-Path $f) { Remove-Item $f; Write-Host "✘ retirado $f" } }

    # Mathematics queda vacío tras la fusión
    if ((Test-Path "Mathematics") -and -not (Get-ChildItem "Mathematics" -Recurse -File)) {
        Remove-Item "Mathematics" -Recurse
        Write-Host "✘ Mathematics/ (vacío) eliminado — fusión completa"
    }
} else {
    Write-Host ""
    Write-Host "Los 10 .js compilados y la carcasa Mathematics/ siguen ahí."
    Write-Host "Cuando verifiques que nada falta:  .\migrar.ps1 -Limpiar"
}

Write-Host ""
Write-Host "Relevo piloto:  npm run 01:todo"
