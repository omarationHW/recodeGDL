<?php
// Verificar si existe tabla y SPs para tipos de bloqueo

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE TIPOS DE BLOQUEO ===\n\n";

    // 1. Buscar tabla en diferentes esquemas
    $stmt = $db->query("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE tablename LIKE '%bloqueo%' OR tablename LIKE '%tipo%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📊 Tablas relacionadas con 'bloqueo' o 'tipo':\n";
    echo str_repeat("-", 80) . "\n";
    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo sprintf("%-20s %-40s %s\n",
                $table['schemaname'],
                $table['tablename'],
                $table['size']
            );
        }
    } else {
        echo "❌ NO se encontraron tablas\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // 2. Buscar SPs relacionados
    echo "🔧 Stored Procedures relacionados:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT
            n.nspname as schema,
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%tipobloqueo%' OR p.proname LIKE '%tipo_bloqueo%'
        ORDER BY n.nspname, p.proname
    ");
    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "✅ {$sp['schema']}.{$sp['nombre']}\n";
            echo "   Parámetros: {$sp['parametros']}\n\n";
        }
    } else {
        echo "❌ NO se encontraron stored procedures\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // 3. Si encontramos una tabla, ver su estructura
    if (count($tables) > 0) {
        $primera_tabla = $tables[0];
        $schema = $primera_tabla['schemaname'];
        $tabla = $primera_tabla['tablename'];

        echo "📋 Estructura de {$schema}.{$tabla}:\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $db->query("
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                is_nullable,
                column_default
            FROM information_schema.columns
            WHERE table_schema = '$schema' AND table_name = '$tabla'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            echo sprintf("%-25s %-20s %s %s\n",
                $col['column_name'],
                $col['data_type'] . ($col['character_maximum_length'] ? "({$col['character_maximum_length']})" : ""),
                $col['is_nullable'] === 'NO' ? 'NOT NULL' : 'NULL',
                $col['column_default'] ? "DEFAULT {$col['column_default']}" : ""
            );
        }
        echo str_repeat("-", 80) . "\n\n";

        // Contar registros
        $stmt = $db->query("SELECT COUNT(*) as total FROM {$schema}.{$tabla}");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        echo "📊 Total registros: {$count}\n\n";

        // Ver primeros 5 registros
        if ($count > 0) {
            echo "🔍 Primeros 5 registros:\n";
            echo str_repeat("-", 80) . "\n";
            $stmt = $db->query("SELECT * FROM {$schema}.{$tabla} LIMIT 5");
            $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
            print_r($records);
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
