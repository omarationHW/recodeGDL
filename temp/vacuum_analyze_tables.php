<?php
/**
 * Script para ejecutar VACUUM ANALYZE en las tablas de giros/adeudos
 */

$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "VACUUM ANALYZE: Optimización de Tablas\n";
echo "========================================\n\n";

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n\n";

    // VACUUM ANALYZE en las tablas principales
    $tables = ['comun.licencias', 'comun.adeudos', 'comun.c_giros'];

    foreach ($tables as $table) {
        echo "Ejecutando VACUUM ANALYZE en {$table}...\n";

        $start = microtime(true);
        $pdo->exec("VACUUM ANALYZE {$table}");
        $end = microtime(true);

        $duration = round(($end - $start) * 1000, 2);
        echo "   ✓ Completado en {$duration} ms\n\n";
    }

    // Test de performance después de VACUUM ANALYZE
    echo "========================================\n";
    echo "TEST POST-VACUUM ANALYZE\n";
    echo "========================================\n\n";

    echo "Ejecutando consulta optimizada...\n";

    $start = microtime(true);

    $stmt = $pdo->prepare("
        SELECT * FROM public.sp_giros_dcon_adeudo(NULL, NULL, NULL, 1, 10)
    ");
    $stmt->execute();
    $results = $stmt->fetchAll();

    $end = microtime(true);
    $duration = round(($end - $start) * 1000, 2);

    echo "✓ Tiempo de ejecución: {$duration} ms\n";
    echo "  Registros retornados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "  Total de giros: " . number_format($results[0]['total_records']) . "\n\n";
    }

    // Comparación
    echo "========================================\n";
    echo "✅ COMPARACIÓN FINAL\n";
    echo "========================================\n\n";

    echo "1. ORIGINAL (EXISTS subqueries):     25,555.88 ms (~25.6 seg)\n";
    echo "2. OPTIMIZADO (LEFT JOIN + CTE):      6,538.36 ms (~6.5 seg)  [-74.4%]\n";
    echo "3. POST-VACUUM ANALYZE:                {$duration} ms\n\n";

    if ($duration < 1000) {
        echo "🎯 EXCELENTE: Performance sub-segundo!\n\n";
    } elseif ($duration < 3000) {
        echo "✓ BUENO: Performance aceptable\n\n";
    } else {
        echo "⚠ Aún lento, investigar más optimizaciones\n\n";
    }

    // Verificar estadísticas de las tablas
    echo "========================================\n";
    echo "ESTADÍSTICAS DE TABLAS\n";
    echo "========================================\n\n";

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
        echo "Tabla: {$stat['tablename']}\n";
        echo "- Tamaño total: {$stat['total_size']}\n";
        echo "- Registros vivos: " . number_format($stat['row_count']) . "\n";
        echo "- Registros muertos: " . number_format($stat['dead_rows']) . "\n";
        echo "- Último ANALYZE: " . ($stat['last_analyze'] ?: 'Nunca') . "\n\n";
    }

    echo "✅ Optimización completa\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}
