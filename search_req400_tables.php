<?php
// Script para buscar tablas relacionadas con requerimientos 400

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el stored procedure actual
    echo "=== STORED PROCEDURE ACTUAL ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_consreq400'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1500) . "...\n";
    }

    // Buscar tablas con "req" o "400"
    echo "\n\n=== TABLAS CON 'req' O '400' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%req%' OR table_name ILIKE '%400%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Ver estructura de tablas relevantes
    foreach ($tables as $table) {
        $schema = $table['table_schema'];
        $tableName = $table['table_name'];

        if (stripos($tableName, '400') !== false ||
            $tableName == 'reqmultasxejecutor' ||
            $tableName == 'reqmultas') {

            echo "\n\n=== ESTRUCTURA DE {$schema}.{$tableName} ===\n";
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$tableName'
                ORDER BY ordinal_position
                LIMIT 30
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            // Datos de ejemplo
            echo "\nDatos de ejemplo:\n";
            try {
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 2");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                if (count($rows) > 0) {
                    foreach ($rows as $i => $row) {
                        echo "  Registro " . ($i + 1) . ":\n";
                        $keys = array_slice(array_keys($row), 0, 8);
                        foreach ($keys as $key) {
                            $val = is_null($row[$key]) ? 'NULL' : substr(trim($row[$key]), 0, 25);
                            echo "    $key: $val\n";
                        }
                    }
                }
            } catch (Exception $e) {
                echo "  Error: " . $e->getMessage() . "\n";
            }
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
