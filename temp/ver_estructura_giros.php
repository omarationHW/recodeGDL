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

    echo "=== ESTRUCTURA DE TABLA c_giros ===\n\n";

    $check = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'c_giros'
        ORDER BY table_schema
    ");

    $tables = $check->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "📋 Tabla: {$table['table_schema']}.{$table['table_name']}\n\n";

            $cols = $pdo->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable
                FROM information_schema.columns
                WHERE table_schema = '{$table['table_schema']}' AND table_name = 'c_giros'
                ORDER BY ordinal_position
            ");

            echo "Columnas:\n";
            foreach ($cols as $col) {
                $type = $col['data_type'];
                if ($col['character_maximum_length']) {
                    $type .= "({$col['character_maximum_length']})";
                }
                $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
                echo "  - {$col['column_name']}: {$type} {$nullable}\n";
            }
            echo "\n";

            // Mostrar algunos registros de ejemplo
            echo "Registros de ejemplo (primeros 5):\n";
            $data = $pdo->query("SELECT * FROM {$table['table_schema']}.c_giros LIMIT 5");
            foreach ($data as $row) {
                echo "  " . json_encode($row) . "\n";
            }
            echo "\n";
        }
    }

    // También ver c_actividades con datos
    echo "=== DATOS DE EJEMPLO c_actividades ===\n\n";
    $data = $pdo->query("SELECT * FROM comun.c_actividades LIMIT 10");
    foreach ($data as $row) {
        echo json_encode($row) . "\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
