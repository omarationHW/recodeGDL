<?php
/**
 * Script para verificar índices en tabla descmultampal
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ANÁLISIS DE ÍNDICES - catastro_gdl.descmultampal ===\n\n";

    // Verificar índices existentes
    echo "1. Índices existentes:\n";
    $indexes = $pdo->query("
        SELECT
            i.relname as index_name,
            a.attname as column_name,
            ix.indisunique as is_unique,
            ix.indisprimary as is_primary
        FROM pg_class t
        JOIN pg_index ix ON t.oid = ix.indrelid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
        JOIN pg_namespace n ON t.relnamespace = n.oid
        WHERE n.nspname = 'catastro_gdl'
        AND t.relname = 'descmultampal'
        ORDER BY i.relname, a.attnum
    ")->fetchAll(PDO::FETCH_ASSOC);

    if (count($indexes) > 0) {
        foreach ($indexes as $idx) {
            $type = $idx['is_primary'] ? '[PRIMARY KEY]' : ($idx['is_unique'] ? '[UNIQUE]' : '[INDEX]');
            echo "   {$type} {$idx['index_name']} -> {$idx['column_name']}\n";
        }
    } else {
        echo "   ⚠ No se encontraron índices en la tabla\n";
    }

    echo "\n2. Estadísticas de la tabla:\n";
    $stats = $pdo->query("
        SELECT
            schemaname,
            relname,
            n_live_tup as registros,
            n_dead_tup as registros_muertos,
            last_vacuum,
            last_autovacuum,
            last_analyze,
            last_autoanalyze
        FROM pg_stat_user_tables
        WHERE schemaname = 'catastro_gdl'
        AND relname = 'descmultampal'
    ")->fetch(PDO::FETCH_ASSOC);

    if ($stats) {
        echo "   Registros vivos: " . number_format($stats['registros']) . "\n";
        echo "   Registros muertos: " . number_format($stats['registros_muertos']) . "\n";
        echo "   Último VACUUM: " . ($stats['last_vacuum'] ?: 'Nunca') . "\n";
        echo "   Último ANALYZE: " . ($stats['last_analyze'] ?: 'Nunca') . "\n";
    } else {
        echo "   ⚠ No se encontraron estadísticas\n";
    }

    echo "\n3. Distribución de valores en id_multa:\n";
    $distribution = $pdo->query("
        SELECT
            COUNT(DISTINCT id_multa) as valores_unicos,
            COUNT(*) as total_registros,
            MIN(id_multa) as min_id,
            MAX(id_multa) as max_id
        FROM catastro_gdl.descmultampal
    ")->fetch(PDO::FETCH_ASSOC);

    echo "   Valores únicos de id_multa: " . number_format($distribution['valores_unicos']) . "\n";
    echo "   Total de registros: " . number_format($distribution['total_registros']) . "\n";
    echo "   Rango: {$distribution['min_id']} - {$distribution['max_id']}\n";

    echo "\n4. Consultas más lentas (simulación):\n";

    // Test sin índice en WHERE con CAST
    $start = microtime(true);
    $pdo->query("SELECT COUNT(*) FROM catastro_gdl.descmultampal WHERE CAST(id_multa AS TEXT) = '74985'")->fetch();
    $time1 = (microtime(true) - $start) * 1000;
    echo "   Con CAST en WHERE: " . number_format($time1, 2) . " ms\n";

    // Test con conversión del parámetro
    $start = microtime(true);
    $pdo->query("SELECT COUNT(*) FROM catastro_gdl.descmultampal WHERE id_multa = 74985")->fetch();
    $time2 = (microtime(true) - $start) * 1000;
    echo "   Sin CAST (directo): " . number_format($time2, 2) . " ms\n";

    $improvement = (($time1 - $time2) / $time1) * 100;
    echo "   Mejora potencial: " . number_format($improvement, 1) . "%\n";

    echo "\n5. Test de consulta completa:\n";
    $start = microtime(true);
    $result = $pdo->query("
        SELECT COUNT(*)
        FROM catastro_gdl.descmultampal
        ORDER BY feccap DESC, id_multa
    ")->fetch();
    $time3 = (microtime(true) - $start) * 1000;
    echo "   Consulta completa con ORDER BY: " . number_format($time3, 2) . " ms\n";
    echo "   Total registros: " . number_format($result[0]) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
