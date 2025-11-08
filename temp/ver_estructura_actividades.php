<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ESTRUCTURA DE TABLA c_actividades ===\n\n";

    // Verificar si la tabla existe
    $check = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'c_actividades'
        ORDER BY table_schema
    ");

    $tables = $check->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "📋 Tabla encontrada: {$table['table_schema']}.{$table['table_name']}\n\n";

            // Obtener columnas
            $cols = $pdo->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
                FROM information_schema.columns
                WHERE table_schema = '{$table['table_schema']}' AND table_name = 'c_actividades'
                ORDER BY ordinal_position
            ");

            echo "Columnas:\n";
            foreach ($cols as $col) {
                $type = $col['data_type'];
                if ($col['character_maximum_length']) {
                    $type .= "({$col['character_maximum_length']})";
                }
                $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
                $default = $col['column_default'] ? "DEFAULT {$col['column_default']}" : '';
                echo "  - {$col['column_name']}: {$type} {$nullable} {$default}\n";
            }
            echo "\n";
        }
    } else {
        echo "⚠️  No se encontró la tabla c_actividades\n\n";

        // Buscar tablas similares
        echo "Buscando tablas similares con 'actividad':\n";
        $similar = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name LIKE '%actividad%'
            ORDER BY table_schema, table_name
        ");

        foreach ($similar as $t) {
            echo "  - {$t['table_schema']}.{$t['table_name']}\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
