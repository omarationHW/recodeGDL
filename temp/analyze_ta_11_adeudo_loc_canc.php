<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "📊 Buscando tabla ta_11_adeudo_loc_canc...\n\n";

// Buscar la tabla
$schema = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name = 'ta_11_adeudo_loc_canc'
")->fetch(PDO::FETCH_ASSOC);

if ($schema) {
    echo "✅ Encontrada en: {$schema['table_schema']}.{$schema['table_name']}\n\n";

    // Ver estructura
    echo "📋 ESTRUCTURA DE LA TABLA:\n\n";
    $cols = $pdo->query("
        SELECT
            column_name,
            udt_name,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = '{$schema['table_schema']}'
          AND table_name = 'ta_11_adeudo_loc_canc'
        ORDER BY ordinal_position
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        echo "   - {$col['column_name']}: {$col['udt_name']}";
        if ($col['character_maximum_length']) {
            echo "({$col['character_maximum_length']})";
        }
        echo " | NULL: {$col['is_nullable']}";
        if ($col['column_default']) {
            echo " | DEFAULT: {$col['column_default']}";
        }
        echo "\n";
    }

    // Contar registros totales
    $count = $pdo->query("
        SELECT COUNT(*) as total
        FROM {$schema['table_schema']}.ta_11_adeudo_loc_canc
    ")->fetch(PDO::FETCH_ASSOC);

    echo "\n📈 Total de registros: {$count['total']}\n\n";

    // Ver registros de ejemplo si hay
    if ($count['total'] > 0) {
        echo "📊 REGISTROS DE EJEMPLO (primeros 3):\n\n";
        $rows = $pdo->query("
            SELECT * FROM {$schema['table_schema']}.ta_11_adeudo_loc_canc
            LIMIT 3
        ")->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "   Registro " . ($i + 1) . ":\n";
            foreach ($row as $k => $v) {
                echo "      $k: $v\n";
            }
            echo "\n";
        }
    } else {
        echo "   ⚠️  La tabla está vacía\n\n";
    }

    // Buscar índices
    echo "🔑 ÍNDICES Y CLAVES:\n\n";
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
        WHERE t.relname = 'ta_11_adeudo_loc_canc'
          AND t.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = '{$schema['table_schema']}')
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

    // Buscar tablas relacionadas
    echo "\n\n🔗 TABLAS POSIBLEMENTE RELACIONADAS:\n\n";

    $related = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = '{$schema['table_schema']}'
          AND table_name LIKE 'ta_11_adeudo%'
        ORDER BY table_name
    ")->fetchAll(PDO::FETCH_COLUMN);

    foreach ($related as $table) {
        echo "   - $table\n";
    }

    // Buscar stored procedures que usen esta tabla
    echo "\n\n📦 STORED PROCEDURES QUE USAN ESTA TABLA:\n\n";

    $sps = $pdo->query("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_type = 'FUNCTION'
          AND routine_definition ILIKE '%ta_11_adeudo_loc_canc%'
        ORDER BY routine_name
    ")->fetchAll(PDO::FETCH_COLUMN);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "   - $sp\n";
        }
    } else {
        echo "   ⚠️  No se encontraron SPs que usen esta tabla\n";
    }

} else {
    echo "❌ Tabla no encontrada\n";
}
