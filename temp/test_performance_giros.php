<?php
/**
 * Script para probar el rendimiento del stored procedure sp_giros_dcon_adeudo
 */

$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST RENDIMIENTO: sp_giros_dcon_adeudo\n";
echo "========================================\n\n";

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n\n";

    // TEST 1: Medir tiempo de ejecución sin filtros (primera llamada - estadísticas)
    echo "1. TEST: Primera llamada (sin filtros) - Simula loadEstadisticas()\n";
    echo "   Parámetros: NULL, NULL, NULL, 1, 10\n";

    $start = microtime(true);

    $stmt = $pdo->prepare("
        SELECT * FROM public.sp_giros_dcon_adeudo(
            :p_year,
            :p_giro,
            :p_min_debt,
            :p_page,
            :p_limit
        )
    ");

    $stmt->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => null,
        'p_page' => 1,
        'p_limit' => 10
    ]);

    $results = $stmt->fetchAll();
    $end = microtime(true);
    $duration = round(($end - $start) * 1000, 2);

    echo "   ✓ Tiempo de ejecución: {$duration} ms\n";
    echo "   Registros retornados: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "   Total de giros: " . number_format($results[0]['total_records']) . "\n";
    }
    echo "\n";

    // TEST 2: Medir tiempo con EXPLAIN ANALYZE
    echo "2. TEST: EXPLAIN ANALYZE para ver plan de ejecución\n";

    $explain = $pdo->query("
        EXPLAIN ANALYZE
        SELECT * FROM public.sp_giros_dcon_adeudo(NULL, NULL, NULL, 1, 10)
    ")->fetchAll();

    echo "   Plan de ejecución:\n";
    foreach ($explain as $line) {
        echo "   " . $line['QUERY PLAN'] . "\n";
    }
    echo "\n";

    // TEST 3: Consulta de todos los registros (exportación)
    echo "3. TEST: Consulta completa sin paginación (Simula exportToExcel)\n";
    echo "   Parámetros: NULL, NULL, NULL, 1, 999999\n";

    $start = microtime(true);

    $stmt->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => null,
        'p_page' => 1,
        'p_limit' => 999999
    ]);

    $allResults = $stmt->fetchAll();
    $end = microtime(true);
    $duration = round(($end - $start) * 1000, 2);

    echo "   ✓ Tiempo de ejecución: {$duration} ms\n";
    echo "   Total de registros: " . count($allResults) . "\n\n";

    // TEST 4: Probar el stored procedure de reporte
    echo "4. TEST: sp_report_giros_dcon_adeudo (sin paginación)\n";

    $start = microtime(true);

    $stmt2 = $pdo->prepare("
        SELECT * FROM public.sp_report_giros_dcon_adeudo(
            :p_year,
            :p_giro,
            :p_min_debt
        )
    ");

    $stmt2->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => null
    ]);

    $reportResults = $stmt2->fetchAll();
    $end = microtime(true);
    $duration = round(($end - $start) * 1000, 2);

    echo "   ✓ Tiempo de ejecución: {$duration} ms\n";
    echo "   Total de registros: " . count($reportResults) . "\n\n";

    // TEST 5: Verificar índices existentes
    echo "5. TEST: Verificar índices en tablas relacionadas\n";

    $indices = $pdo->query("
        SELECT
            schemaname,
            tablename,
            indexname,
            indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename IN ('licencias', 'adeudos', 'c_giros')
        ORDER BY tablename, indexname
    ")->fetchAll();

    echo "   Índices encontrados:\n";
    foreach ($indices as $idx) {
        echo "   - {$idx['tablename']}.{$idx['indexname']}\n";
        echo "     {$idx['indexdef']}\n";
    }
    echo "\n";

    // TEST 6: Estadísticas de las tablas
    echo "6. TEST: Tamaño y estadísticas de tablas\n";

    $stats = $pdo->query("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
            n_live_tup as row_count,
            n_dead_tup as dead_rows,
            last_vacuum,
            last_autovacuum,
            last_analyze,
            last_autoanalyze
        FROM pg_stat_user_tables
        WHERE schemaname = 'comun'
        AND tablename IN ('licencias', 'adeudos', 'c_giros')
        ORDER BY tablename
    ")->fetchAll();

    foreach ($stats as $stat) {
        echo "   Tabla: {$stat['tablename']}\n";
        echo "   - Tamaño total: {$stat['total_size']}\n";
        echo "   - Registros vivos: " . number_format($stat['row_count']) . "\n";
        echo "   - Registros muertos: " . number_format($stat['dead_rows']) . "\n";
        echo "   - Último VACUUM: " . ($stat['last_vacuum'] ?: 'Nunca') . "\n";
        echo "   - Último ANALYZE: " . ($stat['last_analyze'] ?: 'Nunca') . "\n";
        echo "\n";
    }

    echo "========================================\n";
    echo "✅ DIAGNÓSTICO DE RENDIMIENTO COMPLETO\n";
    echo "========================================\n\n";

    echo "RECOMENDACIONES:\n";
    echo "1. Si el tiempo > 3000ms, considerar:\n";
    echo "   - Crear índices en id_giro, cvecuenta, cuentas\n";
    echo "   - Ejecutar VACUUM ANALYZE en las tablas\n";
    echo "   - Optimizar la consulta del SP\n\n";

    echo "2. Si hay muchos dead_rows (>10% de row_count):\n";
    echo "   - Ejecutar VACUUM FULL en las tablas\n\n";

    echo "3. Si last_analyze es NULL o muy antiguo:\n";
    echo "   - Ejecutar ANALYZE en las tablas\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}
