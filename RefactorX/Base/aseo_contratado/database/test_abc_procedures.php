<?php
/**
 * ============================================
 * TEST SCRIPT - ABC CATALOG PROCEDURES
 * Module: aseo_contratado
 * ============================================
 *
 * Tests basic functionality of all ABC procedures
 */

$host = '192.168.6.146';
$db = 'padron_licencias';
$user = 'refact';
$pass = 'FF)-BQk2';

echo "===============================================\n";
echo "TESTING ABC CATALOG STORED PROCEDURES\n";
echo "===============================================\n\n";

$connString = "host={$host} dbname={$db} user={$user} password={$pass}";
$conn = @pg_connect($connString);

if (!$conn) {
    die("ERROR: No se pudo conectar\n");
}

echo "✓ Conexión establecida\n\n";

// Test counter
$totalTests = 0;
$passedTests = 0;
$failedTests = 0;

// Helper function to run test
function runTest($conn, $testName, $sql) {
    global $totalTests, $passedTests, $failedTests;
    $totalTests++;

    echo "Test {$totalTests}: {$testName}\n";
    echo "  SQL: {$sql}\n";

    $result = @pg_query($conn, $sql);

    if ($result === false) {
        echo "  ✗ FAILED: " . pg_last_error($conn) . "\n\n";
        $failedTests++;
        return null;
    }

    $rowCount = pg_num_rows($result);
    echo "  ✓ PASSED - Rows returned: {$rowCount}\n";

    if ($rowCount > 0) {
        $firstRow = pg_fetch_assoc($result);
        echo "  Sample: " . json_encode($firstRow, JSON_UNESCAPED_UNICODE) . "\n";
    }
    echo "\n";

    $passedTests++;
    return $result;
}

echo "-----------------------------------------------\n";
echo "1. ABC_Cves_Operacion Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List operation codes", "SELECT * FROM sp_cves_operacion_list()");

echo "-----------------------------------------------\n";
echo "2. ABC_Empresas Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List companies", "SELECT * FROM sp_empresas_list() LIMIT 5");
runTest($conn, "List company types", "SELECT * FROM sp_tipos_emp_list()");

echo "-----------------------------------------------\n";
echo "3. ABC_Gastos Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List gastos (FIXED)", "SELECT * FROM sp_gastos_list()");
runTest($conn, "Get gastos", "SELECT * FROM sp_gastos_get()");

echo "-----------------------------------------------\n";
echo "4. ABC_Recargos Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List recargos", "SELECT * FROM sp_recargos_list(NULL) LIMIT 5");

echo "-----------------------------------------------\n";
echo "5. ABC_Recaudadoras Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List recaudadoras", "SELECT * FROM sp_list_recaudadoras()");
runTest($conn, "Get next num", "SELECT * FROM sp_get_next_num_recaudadora()");

echo "-----------------------------------------------\n";
echo "6. ABC_Tipos_Aseo Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List tipos aseo", "SELECT * FROM sp_tipos_aseo_list()");

echo "-----------------------------------------------\n";
echo "7. ABC_Tipos_Emp Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List tipos empresa", "SELECT * FROM sp_tipos_emp_list()");

echo "-----------------------------------------------\n";
echo "8. ABC_Und_Recolec Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List unidades", "SELECT * FROM sp_unidades_recoleccion_list(NULL) LIMIT 5");

echo "-----------------------------------------------\n";
echo "9. ABC_Zonas Tests\n";
echo "-----------------------------------------------\n";
runTest($conn, "List zonas", "SELECT * FROM sp_zonas_list() LIMIT 5");

pg_close($conn);

echo "===============================================\n";
echo "TEST SUMMARY\n";
echo "===============================================\n";
echo "Total tests: {$totalTests}\n";
echo "Passed: {$passedTests}\n";
echo "Failed: {$failedTests}\n";
echo "\n";

if ($failedTests === 0) {
    echo "✓ ALL TESTS PASSED\n";
    exit(0);
} else {
    echo "✗ SOME TESTS FAILED\n";
    exit(1);
}
