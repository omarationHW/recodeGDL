<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "📊 ANÁLISIS DE ta_11_ade_loc_canc\n";
echo "==================================\n\n";

// Estructura
echo "📋 ESTRUCTURA DE LA TABLA:\n\n";
$cols = $pdo->query("
    SELECT
        column_name,
        udt_name,
        character_maximum_length,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'publico'
      AND table_name = 'ta_11_ade_loc_canc'
    ORDER BY ordinal_position
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($cols as $col) {
    echo "   {$col['column_name']}: {$col['udt_name']}";
    if ($col['character_maximum_length']) {
        echo "({$col['character_maximum_length']})";
    }
    echo " | NULL: {$col['is_nullable']}";
    if ($col['column_default']) {
        echo " | DEFAULT: {$col['column_default']}";
    }
    echo "\n";
}

// Contar registros
$count = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_ade_loc_canc")->fetch(PDO::FETCH_ASSOC);
echo "\n📈 Total de registros: {$count['total']}\n\n";

// Ver registros de ejemplo si hay
if ($count['total'] > 0) {
    echo "📊 REGISTROS DE EJEMPLO (primeros 5):\n\n";
    $rows = $pdo->query("SELECT * FROM publico.ta_11_ade_loc_canc LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $k => $v) {
            echo "   $k: " . ($v !== null ? $v : 'NULL') . "\n";
        }
        echo "\n";
    }

    // Analizar datos
    echo "📊 ANÁLISIS DE DATOS:\n\n";

    // Rango de fechas
    $dates = $pdo->query("
        SELECT
            MIN(fecha_cancelacion) as min_fecha,
            MAX(fecha_cancelacion) as max_fecha,
            COUNT(DISTINCT id_local) as locales_distintos,
            COUNT(DISTINCT num_mercado) as mercados_distintos
        FROM publico.ta_11_ade_loc_canc
    ")->fetch(PDO::FETCH_ASSOC);

    echo "   Fecha más antigua: {$dates['min_fecha']}\n";
    echo "   Fecha más reciente: {$dates['max_fecha']}\n";
    echo "   Locales distintos: {$dates['locales_distintos']}\n";
    echo "   Mercados distintos: {$dates['mercados_distintos']}\n\n";

    // Top 5 mercados con más cancelaciones
    echo "   Top 5 mercados con más adeudos cancelados:\n\n";
    $top = $pdo->query("
        SELECT
            num_mercado,
            COUNT(*) as total_cancelaciones,
            SUM(importe) as importe_total
        FROM publico.ta_11_ade_loc_canc
        GROUP BY num_mercado
        ORDER BY total_cancelaciones DESC
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($top as $t) {
        echo "      Mercado {$t['num_mercado']}: {$t['total_cancelaciones']} cancelaciones | Importe: \${$t['importe_total']}\n";
    }

} else {
    echo "⚠️  La tabla está vacía\n";
}

// Buscar índices
echo "\n\n🔑 ÍNDICES Y CLAVES:\n\n";
$indexes = $pdo->query("
    SELECT
        i.relname as index_name,
        a.attname as column_name,
        ix.indisprimary as is_primary,
        ix.indisunique as is_unique
    FROM pg_class t
    JOIN pg_index ix ON t.oid = ix.indrelid
    JOIN pg_class i ON i.oid = ix.indexrelid
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
    WHERE t.relname = 'ta_11_ade_loc_canc'
      AND t.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'publico')
    ORDER BY i.relname, a.attnum
")->fetchAll(PDO::FETCH_ASSOC);

if (count($indexes) > 0) {
    $current_index = '';
    foreach ($indexes as $idx) {
        if ($idx['index_name'] != $current_index) {
            $type = $idx['is_primary'] == 't' ? '[PRIMARY KEY]' : ($idx['is_unique'] == 't' ? '[UNIQUE]' : '[INDEX]');
            echo "   {$idx['index_name']} $type\n";
            $current_index = $idx['index_name'];
        }
        echo "      - {$idx['column_name']}\n";
    }
} else {
    echo "   ⚠️  No se encontraron índices\n";
}

// Buscar SPs que usen esta tabla
echo "\n\n📦 STORED PROCEDURES QUE USAN ESTA TABLA:\n\n";
$sps = $pdo->query("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'public'
      AND routine_type = 'FUNCTION'
      AND routine_definition ILIKE '%ta_11_ade_loc_canc%'
    ORDER BY routine_name
")->fetchAll(PDO::FETCH_COLUMN);

if (count($sps) > 0) {
    foreach ($sps as $sp) {
        echo "   - $sp\n";
    }
} else {
    echo "   ⚠️  No se encontraron SPs que usen esta tabla\n";
}

// Buscar en archivos SQL
echo "\n\n📄 ARCHIVOS SQL RELACIONADOS:\n\n";
$sqlFiles = glob(__DIR__ . '/../RefactorX/Base/mercados/database/database/*ade*loc*canc*.sql');
if (count($sqlFiles) > 0) {
    foreach ($sqlFiles as $file) {
        echo "   - " . basename($file) . "\n";
    }
} else {
    $sqlFiles = glob(__DIR__ . '/../RefactorX/Base/mercados/database/database/*Cond*.sql');
    if (count($sqlFiles) > 0) {
        echo "   Archivos relacionados con condonaciones:\n";
        foreach ($sqlFiles as $file) {
            echo "   - " . basename($file) . "\n";
        }
    } else {
        echo "   ⚠️  No se encontraron archivos SQL relacionados\n";
    }
}
