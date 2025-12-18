<?php
// Script para buscar tablas relacionadas con pagos múltiples

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el contenido del stored procedure existente
    echo "=== CONTENIDO DEL STORED PROCEDURE recaudadora_consmulpagos ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_consmulpagos'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n";
    } else {
        echo "  (No se encontró el stored procedure)\n";
    }

    // Buscar tablas relacionadas con pagos
    echo "\n\n=== TABLAS RELACIONADAS CON 'PAGO' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%pago%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }

        // Mostrar detalles de las primeras tablas más relevantes
        $relevantTables = ['public.d_pagos', 'public.pagos', 'publico.pagos'];

        foreach ($tables as $table) {
            $schema = $table['table_schema'];
            $tableName = $table['table_name'];
            $fullName = "{$schema}.{$tableName}";

            // Solo mostrar detalles de tablas relevantes o que contengan "pago" directamente
            if (in_array($fullName, $relevantTables) ||
                ($tableName == 'pagos' || $tableName == 'd_pagos' || stripos($tableName, 'multa') !== false)) {

                echo "\n=== ESTRUCTURA DE {$schema}.{$tableName} ===\n";
                $stmt = $pdo->query("
                    SELECT column_name, data_type, character_maximum_length
                    FROM information_schema.columns
                    WHERE table_schema = '$schema'
                    AND table_name = '$tableName'
                    ORDER BY ordinal_position
                    LIMIT 20
                ");
                $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
                }

                // Ver datos de ejemplo
                echo "\nDatos de ejemplo (2 registros):\n";
                try {
                    $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 2");
                    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                    if (count($rows) > 0) {
                        $firstRow = $rows[0];
                        $keys = array_slice(array_keys($firstRow), 0, 8);
                        foreach ($rows as $i => $row) {
                            echo "  Registro " . ($i + 1) . ": ";
                            foreach ($keys as $key) {
                                echo "$key=" . (is_null($row[$key]) ? 'NULL' : substr($row[$key], 0, 20)) . " ";
                            }
                            echo "\n";
                        }
                    } else {
                        echo "  (No hay datos)\n";
                    }
                } catch (Exception $e) {
                    echo "  Error: " . $e->getMessage() . "\n";
                }
            }
        }
    } else {
        echo "  (No se encontraron tablas relacionadas)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
