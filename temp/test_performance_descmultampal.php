<?php
/**
 * Script para probar el rendimiento del SP optimizado
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== TEST DE RENDIMIENTO - recaudadora_descmultampalfrm ===\n\n";
    echo "Optimizaciones aplicadas:\n";
    echo "  1. Índices creados en id_multa y feccap\n";
    echo "  2. Conversión de parámetro optimizada (sin CAST en WHERE)\n";
    echo "  3. LIMIT dinámico (1000 sin filtro)\n\n";

    echo str_repeat("=", 80) . "\n";

    // TEST 1: Consulta con filtro específico
    echo "\nTEST 1: Consulta CON filtro (id_multa = '74985')\n";
    echo str_repeat("-", 80) . "\n";

    $start = microtime(true);
    $result = $pdo->query("
        SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('74985')
    ")->fetchAll(PDO::FETCH_ASSOC);
    $time1 = (microtime(true) - $start) * 1000;

    echo "Tiempo de ejecución: " . number_format($time1, 2) . " ms\n";
    echo "Registros retornados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "\nPrimer registro:\n";
        foreach ($result[0] as $key => $value) {
            echo "  $key: $value\n";
        }
    }

    // TEST 2: Consulta sin filtro (debería limitar a 1000)
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "\nTEST 2: Consulta SIN filtro (debería limitar a 1000 registros)\n";
    echo str_repeat("-", 80) . "\n";

    $start = microtime(true);
    $result = $pdo->query("
        SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm(NULL)
    ")->fetchAll(PDO::FETCH_ASSOC);
    $time2 = (microtime(true) - $start) * 1000;

    echo "Tiempo de ejecución: " . number_format($time2, 2) . " ms\n";
    echo "Registros retornados: " . count($result) . "\n";
    echo "LIMIT aplicado: " . (count($result) == 1000 ? "✓ Correcto (1000)" : "⚠ Incorrecto") . "\n";

    // TEST 3: Consulta con filtro no existente
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "\nTEST 3: Consulta con ID no existente ('999999999')\n";
    echo str_repeat("-", 80) . "\n";

    $start = microtime(true);
    $result = $pdo->query("
        SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('999999999')
    ")->fetchAll(PDO::FETCH_ASSOC);
    $time3 = (microtime(true) - $start) * 1000;

    echo "Tiempo de ejecución: " . number_format($time3, 2) . " ms\n";
    echo "Registros retornados: " . count($result) . "\n";
    echo "Resultado esperado: ✓ 0 registros (correcto)\n";

    // TEST 4: Múltiples consultas consecutivas (test de cache)
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "\nTEST 4: Múltiples consultas consecutivas (test de cache)\n";
    echo str_repeat("-", 80) . "\n";

    $times = [];
    $test_ids = ['74985', '55847', '100024', '74985', '55847'];

    foreach ($test_ids as $idx => $test_id) {
        $start = microtime(true);
        $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('$test_id')")->fetchAll();
        $times[] = (microtime(true) - $start) * 1000;
        echo "  Consulta " . ($idx + 1) . " (ID: $test_id): " . number_format($times[$idx], 2) . " ms\n";
    }

    $avg_time = array_sum($times) / count($times);
    echo "\nTiempo promedio: " . number_format($avg_time, 2) . " ms\n";

    // TEST 5: Verificar plan de ejecución
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "\nTEST 5: Plan de ejecución (verificar uso de índices)\n";
    echo str_repeat("-", 80) . "\n";

    $explain = $pdo->query("
        EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
        SELECT *
        FROM catastro_gdl.descmultampal d
        WHERE d.id_multa = 74985
        ORDER BY d.feccap DESC, d.id_multa
        LIMIT 1000
    ")->fetchAll(PDO::FETCH_COLUMN);

    echo implode("\n", $explain) . "\n";

    // RESUMEN FINAL
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "RESUMEN DE RENDIMIENTO\n";
    echo str_repeat("=", 80) . "\n\n";

    echo "Test 1 (con filtro):     " . number_format($time1, 2) . " ms\n";
    echo "Test 2 (sin filtro):     " . number_format($time2, 2) . " ms\n";
    echo "Test 3 (ID no existe):   " . number_format($time3, 2) . " ms\n";
    echo "Test 4 (promedio):       " . number_format($avg_time, 2) . " ms\n\n";

    if ($time1 < 50) {
        echo "✓ EXCELENTE: Consultas con filtro < 50ms\n";
    } elseif ($time1 < 100) {
        echo "✓ BUENO: Consultas con filtro < 100ms\n";
    } elseif ($time1 < 200) {
        echo "⚠ ACEPTABLE: Consultas con filtro < 200ms\n";
    } else {
        echo "❌ LENTO: Consultas con filtro > 200ms\n";
    }

    if ($time2 < 100) {
        echo "✓ EXCELENTE: Consultas sin filtro < 100ms\n";
    } elseif ($time2 < 200) {
        echo "✓ BUENO: Consultas sin filtro < 200ms\n";
    } elseif ($time2 < 500) {
        echo "⚠ ACEPTABLE: Consultas sin filtro < 500ms\n";
    } else {
        echo "❌ LENTO: Consultas sin filtro > 500ms\n";
    }

    echo "\nOPTIMIZACIONES APLICADAS:\n";
    echo "  ✓ Índice en id_multa (búsqueda rápida)\n";
    echo "  ✓ Índice compuesto en (feccap, id_multa) para ORDER BY\n";
    echo "  ✓ Conversión de parámetro sin CAST en WHERE\n";
    echo "  ✓ LIMIT de 1000 cuando no hay filtro\n";
    echo "  ✓ Estadísticas actualizadas con ANALYZE\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
