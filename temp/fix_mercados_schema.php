<?php
/**
 * CORRECTOR AUTOMÁTICO DE SCHEMA "mercados"
 * Reemplaza mercados.nombre_sp por public.nombre_sp en archivos SQL
 */

echo "========================================\n";
echo "CORRECTOR DE SCHEMA MERCADOS\n";
echo "========================================\n\n";

// Archivos con error de schema "mercados"
$archivos = [
    'RptAdeudosEnergia_CORREGIDO.sql',
    'RptAdeudosLocales_CORREGIDO.sql',
    'RptCaratulaDatos_CORREGIDO.sql',
    'RptCaratulaEnergia_CORREGIDO.sql',
    'RptCuentaPublica_CORREGIDO.sql',
    'RptEmisionEnergia_CORREGIDO.sql',
    'RptEmisionLaser_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_get_recargos_mes_abastos_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_get_requerimientos_abastos_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos_CORREGIDO.sql'
];

$sqlDir = __DIR__ . '/../RefactorX/Base/mercados/database/database/';
$fixed = 0;
$errors = 0;

foreach ($archivos as $archivo) {
    $filePath = $sqlDir . $archivo;

    echo "Procesando: $archivo\n";

    if (!file_exists($filePath)) {
        echo "  ✗ ERROR: Archivo no encontrado\n\n";
        $errors++;
        continue;
    }

    // Leer contenido
    $content = file_get_contents($filePath);

    if ($content === false) {
        echo "  ✗ ERROR: No se pudo leer el archivo\n\n";
        $errors++;
        continue;
    }

    // Realizar reemplazos
    $originalContent = $content;

    // Patrón 1: CREATE OR REPLACE FUNCTION mercados.nombre_sp → public.nombre_sp
    $content = preg_replace(
        '/CREATE OR REPLACE FUNCTION mercados\.(\w+)/i',
        'CREATE OR REPLACE FUNCTION public.$1',
        $content
    );

    // Patrón 2: DROP FUNCTION IF EXISTS mercados.nombre_sp → public.nombre_sp
    $content = preg_replace(
        '/DROP FUNCTION IF EXISTS mercados\.(\w+)/i',
        'DROP FUNCTION IF EXISTS public.$1',
        $content
    );

    // Verificar si hubo cambios
    if ($content === $originalContent) {
        echo "  ⚠ Sin cambios necesarios\n\n";
        continue;
    }

    // Guardar archivo corregido
    $result = file_put_contents($filePath, $content);

    if ($result === false) {
        echo "  ✗ ERROR: No se pudo guardar el archivo\n\n";
        $errors++;
        continue;
    }

    echo "  ✓ Corregido exitosamente\n\n";
    $fixed++;
}

echo "\n========================================\n";
echo "RESUMEN\n";
echo "========================================\n";
echo "Archivos procesados: " . count($archivos) . "\n";
echo "Corregidos:          $fixed ✓\n";
echo "Errores:             $errors ✗\n";
echo "========================================\n";

exit($errors > 0 ? 1 : 0);
