<?php
/**
 * DEPLOYMENT - 9 STORED PROCEDURES FINALES
 *
 * Despliega los 9 stored procedures corregidos sin referencias cross-database
 * Solo usan formato schema.tabla (NO base.schema.tabla)
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
echo "║ DEPLOYMENT - 9 STORED PROCEDURES FINALES                                    ║\n";
echo "║ CORREGIDOS: Solo usan schema.tabla (NO base.schema.tabla)                   ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n";
echo "\n";

$sps = [
    [
        'name' => 'sp_list_cuotas_energia',
        'description' => 'Lista cuotas de energía eléctrica',
        'component' => 'CuotasEnergiaMntto.vue'
    ],
    [
        'name' => 'sp_get_categorias',
        'description' => 'Catálogo de categorías',
        'component' => 'Múltiples componentes',
        'fix' => 'Agregado public. antes de ta_11_categoria'
    ],
    [
        'name' => 'cuotasmdo_listar',
        'description' => 'Lista cuotas de mercado',
        'component' => 'CuotasMdoMntto.vue',
        'fix' => 'Agregado public. antes de ta_11_cuo_locales'
    ],
    [
        'name' => 'fechas_descuento_get_all',
        'description' => 'Fechas de descuento y recargos',
        'component' => 'FechasDescuentoMntto.vue',
        'fix' => 'Corregido typo "publico" -> "public"'
    ],
    [
        'name' => 'sp_insert_cuota_energia',
        'description' => 'Inserta cuota de energía',
        'component' => 'CuotasEnergiaMntto.vue'
    ],
    [
        'name' => 'rpt_adeudos_energia',
        'description' => 'Reporte de adeudos de energía',
        'component' => 'RptAdeudosEnergia.vue'
    ],
    [
        'name' => 'sp_reporte_catalogo_mercados',
        'description' => 'Genera reporte PDF (dummy)',
        'component' => 'Múltiples componentes'
    ],
    [
        'name' => 'sp_rpt_saldos_locales',
        'description' => 'Reporte de saldos por local',
        'component' => 'RptSaldosLocales.vue'
    ],
    [
        'name' => 'sp_rpt_emision_rbos_abastos',
        'description' => 'Emisión de recibos de abastos',
        'component' => 'RptEmisionRbosAbastos.vue'
    ]
];

// Leer el archivo SQL consolidado
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/00_DEPLOY_9_SPS_FINALES.sql';

if (!file_exists($sqlFile)) {
    echo "❌ ERROR: Archivo SQL no encontrado\n";
    echo "Ruta: {$sqlFile}\n";
    exit(1);
}

$sqlContent = file_get_contents($sqlFile);

// Dividir el archivo SQL en bloques por SP
// Cada SP comienza con el patrón "-- SP X/9: nombre_sp"
$pattern = '/-- SP (\d+)\/9: ([a-z_]+)/i';
preg_match_all($pattern, $sqlContent, $matches, PREG_OFFSET_CAPTURE);

$successful = 0;
$failed = 0;
$errors = [];

for ($i = 0; $i < count($matches[0]); $i++) {
    $spNumber = $matches[1][$i][0];
    $spName = $matches[2][$i][0];
    $startPos = $matches[0][$i][1];

    // Encontrar el final del bloque (inicio del siguiente SP o fin del archivo)
    $endPos = ($i < count($matches[0]) - 1) ? $matches[0][$i + 1][1] : strlen($sqlContent);

    // Extraer el SQL del SP
    $spSql = substr($sqlContent, $startPos, $endPos - $startPos);

    // Buscar solo la parte del CREATE FUNCTION (después del DROP)
    $createPos = stripos($spSql, 'CREATE OR REPLACE FUNCTION');
    if ($createPos !== false) {
        $spSql = substr($spSql, $createPos);

        // Encontrar el final de la función (hasta el próximo comentario de sección o fin)
        $nextSectionPos = stripos($spSql, '-- ============================================', 50);
        if ($nextSectionPos !== false) {
            $spSql = substr($spSql, 0, $nextSectionPos);
        }
    }

    echo "[{$spNumber}/9] Desplegando {$spName}...\n";

    $spInfo = $sps[$spNumber - 1];
    echo "    Descripción: {$spInfo['description']}\n";
    echo "    Componente: {$spInfo['component']}\n";

    if (isset($spInfo['fix'])) {
        echo "    🔧 Corrección: {$spInfo['fix']}\n";
    }

    try {
        // Desplegar en padron_licencias
        DB::connection('pgsql')->unprepared($spSql);
        echo "    ✅ {$spName} desplegado exitosamente\n";
        $successful++;
    } catch (Exception $e) {
        echo "    ❌ ERROR al desplegar {$spName}\n";
        $errorMsg = $e->getMessage();
        // Mostrar solo las primeras 200 caracteres del error
        $shortError = strlen($errorMsg) > 200 ? substr($errorMsg, 0, 200) . '...' : $errorMsg;
        echo "    Error: " . $shortError . "\n";
        $failed++;
        $errors[] = "{$spName}: " . $shortError;
    }

    echo "\n";
}

echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ RESUMEN DEL DESPLIEGUE                                                       ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "Total SPs procesados:  9\n";
echo "Exitosos:              {$successful}\n";
echo "Fallidos:              {$failed}\n";
echo "\n";

if ($failed > 0) {
    echo "❌ ERRORES ENCONTRADOS:\n";
    foreach ($errors as $error) {
        echo "   - {$error}\n";
    }
    echo "\n";
    echo "RECOMENDACIÓN: Revisar los errores y corregir el archivo SQL\n";
    echo "Archivo: RefactorX/Base/mercados/database/database/00_DEPLOY_9_SPS_FINALES.sql\n";
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
    echo "Formato: schema.tabla (SIN referencias cross-database base.schema.tabla)\n";
    echo "\n";
    echo "CORRECCIONES APLICADAS:\n";
    echo "  ✅ sp_get_categorias: Agregado public. antes de ta_11_categoria\n";
    echo "  ✅ cuotasmdo_listar: Agregado public. antes de ta_11_cuo_locales\n";
    echo "  ✅ fechas_descuento_get_all: Corregido typo 'publico' -> 'public'\n";
    echo "\n";
}
