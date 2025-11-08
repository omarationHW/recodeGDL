<?php
// Buscar tablas y SPs relacionados con tipo_bloqueo

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BÚSQUEDA DE TIPO_BLOQUEO ===\n\n";

    // 1. Buscar tablas con 'tipo' y 'bloqueo' en el nombre
    echo "📊 Buscando tablas...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename LIKE '%tipo%bloqueo%'
           OR tablename LIKE '%tipobloqueo%'
           OR tablename LIKE '%tiposbloqueo%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "✅ {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "❌ NO se encontraron tablas específicas de tipo_bloqueo\n";
        echo "\nBuscando tablas con solo 'bloqueo'...\n";

        $stmt = $db->query("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE tablename LIKE '%bloqueo%'
            ORDER BY schemaname, tablename
        ");
        $tables_bloqueo = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($tables_bloqueo as $table) {
            echo "  - {$table['schemaname']}.{$table['tablename']}\n";
        }
    }
    echo str_repeat("-", 80) . "\n\n";

    // 2. Buscar SPs relacionados
    echo "🔧 Buscando Stored Procedures...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query("
        SELECT
            n.nspname as schema,
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%tipobloqueo%'
           OR p.proname LIKE '%tipo_bloqueo%'
        ORDER BY n.nspname, p.proname
    ");
    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "✅ {$sp['schema']}.{$sp['nombre']}\n";
            echo "   Parámetros: {$sp['parametros']}\n\n";
        }
    } else {
        echo "❌ NO se encontraron SPs de tipo_bloqueo\n";
    }
    echo str_repeat("-", 80) . "\n\n";

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
