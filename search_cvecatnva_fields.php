<?php
// Script para buscar tablas con campos cvecatnva o cvecuenta

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas que contengan cvecatnva
    echo "=== TABLAS CON CAMPO 'cvecatnva' ===\n";
    $stmt = $pdo->query("
        SELECT DISTINCT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name ILIKE '%cvecatnva%'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }

        // Ver la primera tabla con más detalle
        $firstTable = $tables[0];
        $schema = $firstTable['table_schema'];
        $tableName = $firstTable['table_name'];

        echo "\n=== ESTRUCTURA DE {$schema}.{$tableName} ===\n";
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = '$tableName'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        try {
            $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 2");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if (count($rows) > 0) {
                foreach ($rows as $i => $row) {
                    echo "\nRegistro " . ($i + 1) . ":\n";
                    $keys = array_slice(array_keys($row), 0, 10);
                    foreach ($keys as $key) {
                        $val = is_null($row[$key]) ? 'NULL' : substr(trim($row[$key]), 0, 30);
                        echo "  $key: $val\n";
                    }
                }
            }
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n";
        }
    } else {
        echo "  (No se encontraron tablas con cvecatnva)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
