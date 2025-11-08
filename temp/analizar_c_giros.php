<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "ANÁLISIS: TABLA C_GIROS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // 1. Estructura tabla
    echo "========================================\n";
    echo "1. ESTRUCTURA DE comun.c_giros\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'c_giros'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : '';
        $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : '';
        echo sprintf("  %-25s %s%s %s%s\n",
            $col['column_name'],
            $col['data_type'],
            $length,
            $nullable,
            $default
        );
    }
    echo "\n";

    // 2. Contadores
    echo "========================================\n";
    echo "2. ESTADÍSTICAS GENERALES\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.c_giros");
    $total = $stmt->fetchColumn();
    echo "Total de registros: " . number_format($total) . "\n\n";

    // 3. Índices
    echo "========================================\n";
    echo "3. ÍNDICES EXISTENTES\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            indexname,
            indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'c_giros'
        ORDER BY indexname
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($indices) > 0) {
        foreach ($indices as $idx) {
            echo "  • {$idx['indexname']}\n";
            echo "    {$idx['indexdef']}\n\n";
        }
    } else {
        echo "  ⚠️ NO HAY ÍNDICES (excepto PK)\n\n";
    }

    // 4. Distribución de datos
    echo "========================================\n";
    echo "4. DISTRIBUCIÓN DE DATOS\n";
    echo "========================================\n\n";

    // Por tipo
    $stmt = $pdo->query("
        SELECT tipo, COUNT(*) as total
        FROM comun.c_giros
        GROUP BY tipo
        ORDER BY total DESC
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Por Tipo:\n";
    foreach ($tipos as $tipo) {
        $pct = round(($tipo['total'] / $total) * 100, 2);
        echo sprintf("  %-15s: %s (%s%%)\n",
            $tipo['tipo'] ?? 'NULL',
            number_format($tipo['total']),
            $pct
        );
    }
    echo "\n";

    // Por vigente
    $stmt = $pdo->query("
        SELECT vigente, COUNT(*) as total
        FROM comun.c_giros
        GROUP BY vigente
        ORDER BY vigente
    ");
    $vigentes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Por Vigencia:\n";
    foreach ($vigentes as $vig) {
        $pct = round(($vig['total'] / $total) * 100, 2);
        echo sprintf("  %-15s: %s (%s%%)\n",
            $vig['vigente'] ?? 'NULL',
            number_format($vig['total']),
            $pct
        );
    }
    echo "\n";

    // Por clasificación
    $stmt = $pdo->query("
        SELECT clasificacion, COUNT(*) as total
        FROM comun.c_giros
        GROUP BY clasificacion
        ORDER BY clasificacion
    ");
    $clasifs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Por Clasificación:\n";
    foreach ($clasifs as $clas) {
        $pct = round(($clas['total'] / $total) * 100, 2);
        echo sprintf("  %-15s: %s (%s%%)\n",
            $clas['clasificacion'] ?? 'NULL',
            number_format($clas['total']),
            $pct
        );
    }
    echo "\n";

    // 5. Test performance
    echo "========================================\n";
    echo "5. TEST DE PERFORMANCE\n";
    echo "========================================\n\n";

    // Test 1: Búsqueda por descripción
    echo "Test 1: Búsqueda por descripción (ILIKE '%comercio%')\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*)
        FROM comun.c_giros
        WHERE descripcion ILIKE '%comercio%'
    ");
    $count = $stmt->fetchColumn();
    $duration1 = round((microtime(true) - $start) * 1000, 2);
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration1}ms\n";
    if ($duration1 < 500) {
        echo "  ✅ EXCELENTE\n";
    } else {
        echo "  ⚠️ Puede mejorar con índice\n";
    }
    echo "\n";

    // Test 2: Filtro por tipo
    echo "Test 2: Filtro por tipo = 'L'\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*)
        FROM comun.c_giros
        WHERE tipo = 'L'
    ");
    $count = $stmt->fetchColumn();
    $duration2 = round((microtime(true) - $start) * 1000, 2);
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration2}ms\n";
    if ($duration2 < 200) {
        echo "  ✅ EXCELENTE\n";
    } else {
        echo "  ⚠️ Puede mejorar con índice\n";
    }
    echo "\n";

    // Test 3: Filtro por vigente
    echo "Test 3: Filtro por vigente = 'V'\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*)
        FROM comun.c_giros
        WHERE vigente = 'V'
    ");
    $count = $stmt->fetchColumn();
    $duration3 = round((microtime(true) - $start) * 1000, 2);
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration3}ms\n";
    if ($duration3 < 200) {
        echo "  ✅ EXCELENTE\n";
    } else {
        echo "  ⚠️ Puede mejorar con índice\n";
    }
    echo "\n";

    // Test 4: Consulta completa con paginación
    echo "Test 4: Consulta completa (10 registros con filtros)\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT *
        FROM comun.c_giros
        WHERE tipo = 'L'
        AND vigente = 'V'
        ORDER BY descripcion
        LIMIT 10
    ");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration4 = round((microtime(true) - $start) * 1000, 2);
    echo "  Resultados: " . count($results) . "\n";
    echo "  ⏱ Tiempo: {$duration4}ms\n";
    if ($duration4 < 500) {
        echo "  ✅ EXCELENTE\n";
    } else {
        echo "  ⚠️ Puede mejorar\n";
    }
    echo "\n";

    // 6. Ejemplo de datos
    if (count($results) > 0) {
        echo "========================================\n";
        echo "6. EJEMPLO DE REGISTRO\n";
        echo "========================================\n\n";

        $sample = $results[0];
        foreach ($sample as $key => $value) {
            echo sprintf("  %-25s: %s\n", $key, $value);
        }
        echo "\n";
    }

    // 7. Recomendaciones de índices
    echo "========================================\n";
    echo "7. RECOMENDACIONES\n";
    echo "========================================\n\n";

    $promedio = ($duration1 + $duration2 + $duration3 + $duration4) / 4;
    echo "Tiempo promedio: " . round($promedio, 2) . "ms\n\n";

    echo "Índices recomendados:\n";
    echo "  1. idx_c_giros_tipo - Filtro frecuente\n";
    echo "  2. idx_c_giros_vigente - Filtro frecuente\n";
    echo "  3. idx_c_giros_descripcion_gin - Búsqueda de texto\n";
    echo "  4. idx_c_giros_clasificacion - Para reportes\n";
    echo "\n";

    echo "✅ Análisis completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
