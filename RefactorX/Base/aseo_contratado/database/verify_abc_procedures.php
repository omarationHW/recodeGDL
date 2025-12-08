<?php
/**
 * ============================================
 * VERIFICATION SCRIPT - ABC CATALOG PROCEDURES
 * Module: aseo_contratado
 * Database: padron_licencias at 192.168.6.146
 * ============================================
 *
 * Verifica que todos los stored procedures ABC estén
 * correctamente desplegados en la base de datos
 */

// Configuración de base de datos
$host = '192.168.6.146';
$db = 'padron_licencias';
$user = 'refact';
$pass = 'FF)-BQk2';

// Expected functions per component
$expectedFunctions = [
    'ABC_Cves_Operacion' => [
        'sp_cves_operacion_list',
        'sp_cves_operacion_get',
        'sp_cves_operacion_insert',
        'sp_cves_operacion_update',
        'sp_cves_operacion_delete'
    ],
    'ABC_Empresas' => [
        'sp_empresas_list',
        'sp_empresas_get',
        'sp_empresas_create',
        'sp_empresas_update',
        'sp_empresas_delete',
        'sp_empresas_search',
        'sp_tipos_emp_list'
    ],
    'ABC_Gastos' => [
        'sp_gastos_list',
        'sp_gastos_get',
        'sp_gastos_insert',
        'sp_gastos_update',
        'sp_gastos_delete_all'
    ],
    'ABC_Recargos' => [
        'sp_recargos_list',
        'sp_recargos_create',
        'sp_recargos_update',
        'sp_recargos_delete'
    ],
    'ABC_Recaudadoras' => [
        'sp_list_recaudadoras',
        'sp_get_next_num_recaudadora',
        'sp_insert_recaudadora',
        'sp_update_recaudadora',
        'sp_delete_recaudadora'
    ],
    'ABC_Tipos_Aseo' => [
        'sp_tipos_aseo_list',
        'sp_tipos_aseo_create',
        'sp_tipos_aseo_update',
        'sp_tipos_aseo_delete'
    ],
    'ABC_Tipos_Emp' => [
        'sp_tipos_emp_list',
        'sp_tipos_emp_create',
        'sp_tipos_emp_update',
        'sp_tipos_emp_delete'
    ],
    'ABC_Und_Recolec' => [
        'sp_unidades_recoleccion_list',
        'sp_unidades_recoleccion_create',
        'sp_unidades_recoleccion_update',
        'sp_unidades_recoleccion_delete'
    ],
    'ABC_Zonas' => [
        'sp_zonas_list',
        'sp_zonas_create',
        'sp_zonas_update',
        'sp_zonas_delete'
    ]
];

echo "===============================================\n";
echo "VERIFICATION - ABC CATALOG STORED PROCEDURES\n";
echo "Database: {$db} @ {$host}\n";
echo "===============================================\n\n";

// Conectar
$connString = "host={$host} dbname={$db} user={$user} password={$pass}";
$conn = @pg_connect($connString);

if (!$conn) {
    die("ERROR: No se pudo conectar a la base de datos.\n");
}

echo "✓ Conexión establecida\n\n";

// Query para obtener todas las funciones
$query = "
    SELECT
        proname as function_name,
        pg_get_function_identity_arguments(oid) as arguments,
        prokind
    FROM pg_proc
    WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
      AND proname LIKE 'sp_%'
    ORDER BY proname
";

$result = pg_query($conn, $query);
if (!$result) {
    die("ERROR: " . pg_last_error($conn) . "\n");
}

// Obtener todas las funciones existentes
$existingFunctions = [];
while ($row = pg_fetch_assoc($result)) {
    $existingFunctions[$row['function_name']] = [
        'args' => $row['arguments'],
        'kind' => $row['prokind']
    ];
}

// Verificar cada componente
$totalExpected = 0;
$totalFound = 0;
$totalMissing = 0;
$missingFunctions = [];

foreach ($expectedFunctions as $component => $functions) {
    echo "-----------------------------------------------\n";
    echo "Component: {$component}\n";
    echo "-----------------------------------------------\n";

    $componentFound = 0;
    $componentMissing = 0;

    foreach ($functions as $funcName) {
        $totalExpected++;

        if (isset($existingFunctions[$funcName])) {
            echo "  ✓ {$funcName}";

            // Check if it's a function (not procedure)
            if ($existingFunctions[$funcName]['kind'] === 'f') {
                echo " (FUNCTION)\n";
            } else if ($existingFunctions[$funcName]['kind'] === 'p') {
                echo " ⚠️ WARNING: This is a PROCEDURE, should be FUNCTION!\n";
            } else {
                echo " (unknown kind: {$existingFunctions[$funcName]['kind']})\n";
            }

            $totalFound++;
            $componentFound++;
        } else {
            echo "  ✗ {$funcName} - MISSING\n";
            $totalMissing++;
            $componentMissing++;
            $missingFunctions[] = "{$component}: {$funcName}";
        }
    }

    $componentTotal = $componentFound + $componentMissing;
    echo "\nComponent Summary: {$componentFound}/{$componentTotal} found\n\n";
}

// Resumen final
echo "===============================================\n";
echo "VERIFICATION SUMMARY\n";
echo "===============================================\n";
echo "Expected functions: {$totalExpected}\n";
echo "Found: {$totalFound}\n";
echo "Missing: {$totalMissing}\n";
echo "\n";

if ($totalMissing > 0) {
    echo "MISSING FUNCTIONS:\n";
    foreach ($missingFunctions as $missing) {
        echo "  - {$missing}\n";
    }
    echo "\n";
}

// Check for unexpected functions (starting with sp_ but not in our list)
$allExpectedFlat = [];
foreach ($expectedFunctions as $funcs) {
    $allExpectedFlat = array_merge($allExpectedFlat, $funcs);
}

$unexpectedFunctions = [];
foreach ($existingFunctions as $funcName => $info) {
    if (!in_array($funcName, $allExpectedFlat)) {
        $unexpectedFunctions[] = $funcName;
    }
}

if (count($unexpectedFunctions) > 0) {
    echo "UNEXPECTED FUNCTIONS (not in ABC catalog):\n";
    foreach ($unexpectedFunctions as $unexpected) {
        echo "  - {$unexpected}\n";
    }
    echo "\n";
}

pg_close($conn);

if ($totalMissing === 0) {
    echo "✓ VERIFICATION SUCCESSFUL - All ABC procedures are deployed\n";
    exit(0);
} else {
    echo "✗ VERIFICATION FAILED - Some procedures are missing\n";
    exit(1);
}
