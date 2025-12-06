<?php
/**
 * Script para desplegar 2 SPs auxiliares de Prescripcion.vue
 */

require_once __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

$basePath = 'C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/Base/mercados/database/database/';

$spsFiles = [
    'Prescripcion_sp_listar_adeudos_energia.sql',
    'Prescripcion_sp_listar_prescripciones.sql'
];

echo "\n╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ DEPLOYMENT - 2 SPs AUXILIARES PRESCRIPCION.VUE                              ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

$exitosos = 0;
$fallidos = 0;

foreach ($spsFiles as $index => $file) {
    $num = $index + 1;
    $filePath = $basePath . $file;

    echo "═══════════════════════════════════════════════════════════════════════════════\n";
    echo "[$num/2] Desplegando: {$file}\n";
    echo "═══════════════════════════════════════════════════════════════════════════════\n";

    if (!file_exists($filePath)) {
        echo "❌ ERROR: Archivo no encontrado\n";
        echo "   Ruta: {$filePath}\n\n";
        $fallidos++;
        continue;
    }

    $sql = file_get_contents($filePath);

    if (empty($sql)) {
        echo "❌ ERROR: Archivo vacío\n\n";
        $fallidos++;
        continue;
    }

    // Extraer nombre de función
    if (preg_match('/CREATE OR REPLACE FUNCTION\s+[\w\.]+\.(sp_\w+)\s*\(/i', $sql, $matches)) {
        $funcName = $matches[1];
        echo "   Función: {$funcName}\n";
    } else {
        echo "   Función: (no detectada)\n";
    }

    try {
        DB::connection('pgsql')->unprepared($sql);
        echo "   ✅ DESPLEGADO EXITOSAMENTE\n\n";
        $exitosos++;
    } catch (\Exception $e) {
        echo "   ❌ ERROR AL DESPLEGAR\n";
        echo "   " . $e->getMessage() . "\n\n";
        $fallidos++;
    }
}

echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "RESUMEN FINAL\n";
echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "Total SPs procesados:  " . count($spsFiles) . "\n";
echo "Exitosos:              {$exitosos}\n";
echo "Fallidos:              {$fallidos}\n\n";

if ($fallidos == 0) {
    echo "✅ TODOS LOS STORED PROCEDURES SE DESPLEGARON EXITOSAMENTE\n";
    echo "\n";
    echo "✅ PRESCRIPCION.VUE COMPLETADO AL 100%\n";
} else {
    echo "⚠️  ALGUNOS STORED PROCEDURES FALLARON\n";
}

echo "\n";
