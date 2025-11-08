<?php
// Verificar tablas y SPs de fechas de seguimiento

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE FECHAS DE SEGUIMIENTO ===\n\n";

    // 1. Buscar tablas relacionadas
    echo "📊 Buscando tablas relacionadas con 'fecha'...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE (tablename LIKE '%fechaseg%' OR tablename LIKE '%fecha_seg%' OR tablename LIKE '%seguimiento%')
          AND (schemaname = 'public' OR schemaname = 'comun')
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "✅ {$table['schemaname']}.{$table['tablename']} - {$table['size']}\n";

            // Ver estructura
            $stmt2 = $db->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable
                FROM information_schema.columns
                WHERE table_schema = '{$table['schemaname']}'
                  AND table_name = '{$table['tablename']}'
                ORDER BY ordinal_position
            ");
            $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            echo "   Columnas:\n";
            foreach($cols as $col) {
                $type = $col['data_type'];
                if ($col['character_maximum_length']) {
                    $type .= "({$col['character_maximum_length']})";
                }
                $null = $col['is_nullable'] === 'NO' ? 'NOT NULL' : 'NULL';
                echo "   - {$col['column_name']}: $type $null\n";
            }

            // Contar registros
            try {
                $fullTable = "{$table['schemaname']}.{$table['tablename']}";
                $stmt3 = $db->query("SELECT COUNT(*) as total FROM $fullTable");
                $count = $stmt3->fetch(PDO::FETCH_ASSOC)['total'];
                echo "   Total registros: $count\n";

                if ($count > 0 && $count <= 10) {
                    echo "   Muestra (primeros 3):\n";
                    $stmt4 = $db->query("SELECT * FROM $fullTable LIMIT 3");
                    $rows = $stmt4->fetchAll(PDO::FETCH_ASSOC);
                    foreach($rows as $i => $row) {
                        echo "   " . ($i + 1) . ". " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
                    }
                }
            } catch (Exception $e) {
                echo "   Error contando: {$e->getMessage()}\n";
            }
            echo "\n";
        }
    } else {
        echo "❌ NO se encontraron tablas con 'fechaseg'\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // 2. Buscar SPs relacionados
    foreach (['public', 'comun'] as $schema) {
        echo "🔧 SPs con 'fechaseg' en esquema '$schema':\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $db->query("
            SELECT
                p.proname as nombre,
                pg_get_function_arguments(p.oid) as parametros
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = '$schema'
              AND (p.proname LIKE '%fechaseg%' OR p.proname LIKE '%fecha_seg%')
            ORDER BY p.proname
        ");
        $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($sps) > 0) {
            foreach ($sps as $sp) {
                echo "✅ $schema.{$sp['nombre']}\n";
                echo "   Params: {$sp['parametros']}\n\n";
            }
        } else {
            echo "❌ NO se encontraron SPs\n";
        }
        echo str_repeat("-", 80) . "\n\n";
    }

    echo "\n✅ VERIFICACIÓN COMPLETA\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
