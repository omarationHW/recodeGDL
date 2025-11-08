<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "ANÁLISIS TABLA ANUNCIOS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Buscar tabla de anuncios
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE tablename = 'anuncios'
        AND schemaname = 'comun'
    ");

    $table = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($table) {
        echo "✓ Tabla encontrada: {$table['schemaname']}.{$table['tablename']}\n";
        echo "Tamaño: {$table['size']}\n\n";

        // Conteo de registros
        $countStmt = $pdo->query("SELECT COUNT(*) as total FROM comun.anuncios");
        $count = $countStmt->fetch(PDO::FETCH_ASSOC);
        echo "Total registros: " . number_format($count['total']) . "\n\n";

        // Conteo por estado
        echo "========================================\n";
        echo "DISTRIBUCIÓN POR ESTADO\n";
        echo "========================================\n";
        $statsStmt = $pdo->query("
            SELECT
                vigente,
                COUNT(*) as total
            FROM comun.anuncios
            GROUP BY vigente
            ORDER BY total DESC
        ");
        $stats = $statsStmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($stats as $stat) {
            echo sprintf("%-10s: %s\n", $stat['vigente'], number_format($stat['total']));
        }
        echo "\n";

        // Índices existentes
        echo "========================================\n";
        echo "ÍNDICES EXISTENTES\n";
        echo "========================================\n";
        $idxStmt = $pdo->query("
            SELECT
                indexname,
                indexdef
            FROM pg_indexes
            WHERE schemaname = 'comun'
            AND tablename = 'anuncios'
            ORDER BY indexname
        ");
        $indices = $idxStmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Total índices: " . count($indices) . "\n\n";
        foreach ($indices as $idx) {
            echo "✓ {$idx['indexname']}\n";
            echo "  {$idx['indexdef']}\n\n";
        }

        // Verificar índices necesarios
        echo "========================================\n";
        echo "ÍNDICES RECOMENDADOS\n";
        echo "========================================\n";

        $columnas_importantes = ['vigente', 'zona', 'fecha_otorgamiento', 'id_licencia', 'anuncio'];
        $indices_faltantes = [];

        foreach ($columnas_importantes as $col) {
            $checkIdx = $pdo->query("
                SELECT COUNT(*) as existe
                FROM pg_indexes
                WHERE schemaname = 'comun'
                AND tablename = 'anuncios'
                AND indexdef ILIKE '%{$col}%'
            ");
            $existe = $checkIdx->fetch(PDO::FETCH_ASSOC);

            if ($existe['existe'] == 0) {
                $indices_faltantes[] = $col;
                echo "⚠ Falta índice para: {$col}\n";
            } else {
                echo "✓ Existe índice para: {$col}\n";
            }
        }

        if (count($indices_faltantes) > 0) {
            echo "\nSe recomienda crear índices para: " . implode(', ', $indices_faltantes) . "\n";
        } else {
            echo "\n✅ Todos los índices recomendados existen\n";
        }

        // Test de performance
        echo "\n========================================\n";
        echo "TEST DE PERFORMANCE\n";
        echo "========================================\n\n";

        // Test 1: Sin filtros
        $start = microtime(true);
        $pdo->query("SELECT COUNT(*) FROM comun.anuncios WHERE anuncio > 0");
        $duration1 = round((microtime(true) - $start) * 1000, 2);
        echo "Sin filtros: {$duration1}ms\n";

        // Test 2: Con filtro VIGENTE
        $start = microtime(true);
        $pdo->query("SELECT COUNT(*) FROM comun.anuncios WHERE vigente = 'V'");
        $duration2 = round((microtime(true) - $start) * 1000, 2);
        echo "Con filtro vigente: {$duration2}ms\n";

        // Test 3: Con filtro de fechas (6 meses)
        $start = microtime(true);
        $pdo->query("
            SELECT COUNT(*)
            FROM comun.anuncios
            WHERE fecha_otorgamiento >= CURRENT_DATE - INTERVAL '6 months'
        ");
        $duration3 = round((microtime(true) - $start) * 1000, 2);
        echo "Con filtro fecha (6 meses): {$duration3}ms\n";

        // Test 4: SP de estadísticas actual
        echo "\n--- Test SP Estadísticas ---\n";
        $start = microtime(true);
        $pdo->query("SELECT * FROM comun.consulta_anuncios_estadisticas()");
        $duration4 = round((microtime(true) - $start) * 1000, 2);
        echo "SP estadísticas: {$duration4}ms\n";

        echo "\n";
        if ($duration4 > 1000) {
            echo "⚠️ SP estadísticas es LENTO - Se recomienda optimizar\n";
        } else {
            echo "✅ SP estadísticas tiene buen rendimiento\n";
        }

    } else {
        echo "✗ No se encontró la tabla comun.anuncios\n";
    }

    echo "\n✅ Análisis completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
