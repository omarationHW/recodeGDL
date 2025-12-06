<?php
/**
 * DEPLOYMENT - 4 SPs FASE 2
 *
 * Despliega los stored procedures para los componentes de FASE 2
 * - RptPagosAno.vue
 * - RptPagosCaja.vue
 * - RptResumenPagos.vue
 * - ReporteGeneralMercados.vue
 *
 * Base: padron_licencias
 * Fecha: 2025-12-05
 */

// Configuración de Laravel
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "\n";
echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ DEPLOYMENT - 4 SPs FASE 2                                                   ║\n";
echo "║ Componentes: RptPagosAno, RptPagosCaja, RptResumenPagos,                   ║\n";
echo "║             ReporteGeneralMercados                                           ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n";
echo "\n";

$sps = [
    [
        'name' => 'sp_rpt_pagos_ano',
        'file' => __DIR__ . '/../RefactorX/Base/mercados/database/database/RptPagosAno_sp_rpt_pagos_ano.sql',
        'component' => 'RptPagosAno.vue'
    ],
    [
        'name' => 'sp_rpt_pagos_caja',
        'file' => __DIR__ . '/../RefactorX/Base/mercados/database/database/RptPagosCaja_sp_rpt_pagos_caja.sql',
        'component' => 'RptPagosCaja.vue'
    ],
    [
        'name' => 'sp_rpt_resumen_pagos',
        'file' => __DIR__ . '/../RefactorX/Base/mercados/database/database/RptResumenPagos_sp_rpt_resumen_pagos.sql',
        'component' => 'RptResumenPagos.vue'
    ],
    [
        'name' => 'sp_reporte_general_mercados',
        'file' => __DIR__ . '/../RefactorX/Base/mercados/database/database/ReporteGeneralMercados_sp_reporte_general_mercados.sql',
        'component' => 'ReporteGeneralMercados.vue'
    ]
];

$successful = 0;
$failed = 0;
$errors = [];

foreach ($sps as $index => $sp) {
    $num = $index + 1;
    echo "[{$num}/4] Desplegando {$sp['name']}...\n";

    if (!file_exists($sp['file'])) {
        echo "    ❌ ERROR: Archivo no encontrado\n";
        echo "    Ruta: {$sp['file']}\n";
        $failed++;
        $errors[] = "{$sp['name']}: Archivo no encontrado";
        continue;
    }

    $sql = file_get_contents($sp['file']);

    try {
        DB::connection('pgsql')->unprepared($sql);
        echo "    ✅ {$sp['name']} desplegado exitosamente\n";
        echo "    Componente: {$sp['component']}\n";
        $successful++;
    } catch (Exception $e) {
        echo "    ❌ ERROR al desplegar {$sp['name']}\n";
        echo "    " . $e->getMessage() . "\n";
        $failed++;
        $errors[] = "{$sp['name']}: " . $e->getMessage();
    }

    echo "\n";
}

echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ RESUMEN DEL DESPLIEGUE                                                       ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "Total SPs procesados:  4\n";
echo "Exitosos:              {$successful}\n";
echo "Fallidos:              {$failed}\n";
echo "\n";

if ($failed > 0) {
    echo "❌ ERRORES ENCONTRADOS:\n";
    foreach ($errors as $error) {
        echo "   - {$error}\n";
    }
    echo "\n";
    exit(1);
} else {
    echo "✅ TODOS LOS STORED PROCEDURES SE DESPLEGARON EXITOSAMENTE\n";
    echo "\n";
    echo "Los SPs están listos para ser usados por:\n";
    foreach ($sps as $sp) {
        echo "  - {$sp['component']}\n";
    }
    echo "\n";
    echo "Base de datos: padron_licencias (conexión pgsql)\n";
    echo "\n";
}
