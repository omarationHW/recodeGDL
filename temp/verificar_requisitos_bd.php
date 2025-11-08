<?php
// Verificar tabla y SPs de requisitos

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias;options=--search_path=public,comun', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE REQUISITOS ===\n\n";

    // 1. Buscar tablas con 'requisito' en el nombre
    echo "📊 Buscando tablas...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE tablename LIKE '%requisito%'
           OR tablename LIKE '%reqs%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "✅ {$table['schemaname']}.{$table['tablename']} - {$table['size']}\n";
        }
    } else {
        echo "❌ NO se encontraron tablas\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // 2. Buscar SPs en public y comun
    foreach (['public', 'comun'] as $schema) {
        echo "🔧 SPs en esquema '$schema':\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $db->query("
            SELECT
                p.proname as nombre,
                pg_get_function_arguments(p.oid) as parametros
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = '$schema'
              AND (p.proname LIKE '%requisito%' OR p.proname LIKE '%reqs%')
            ORDER BY p.proname
        ");
        $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($sps) > 0) {
            foreach ($sps as $sp) {
                echo "✅ $schema.{$sp['nombre']}\n";
                echo "   Parámetros: {$sp['parametros']}\n\n";
            }
        } else {
            echo "❌ NO se encontraron SPs\n";
        }
        echo str_repeat("-", 80) . "\n\n";
    }

    // 3. Si encontramos tabla, ver estructura
    if (count($tables) > 0) {
        $primera = $tables[0];
        echo "📋 Estructura de {$primera['schemaname']}.{$primera['tablename']}:\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $db->query("
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                is_nullable,
                column_default
            FROM information_schema.columns
            WHERE table_schema = '{$primera['schemaname']}'
              AND table_name = '{$primera['tablename']}'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }

            echo sprintf("%-25s %-20s %-10s %s\n",
                $col['column_name'],
                $type,
                $col['is_nullable'] === 'NO' ? 'NOT NULL' : 'NULL',
                $col['column_default'] ? "DEFAULT {$col['column_default']}" : ""
            );
        }
        echo str_repeat("-", 80) . "\n";

        // Contar registros
        $stmt = $db->query("SELECT COUNT(*) as total FROM {$primera['schemaname']}.{$primera['tablename']}");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        echo "📊 Total registros: {$count}\n\n";

        // Primeros 5 registros
        if ($count > 0) {
            echo "🔍 Primeros 5 registros:\n";
            $stmt = $db->query("SELECT * FROM {$primera['schemaname']}.{$primera['tablename']} LIMIT 5");
            $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
            print_r($records);
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
