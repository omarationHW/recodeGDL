<?php
// Script para buscar tablas relacionadas con bloqueos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas relacionadas con bloqueos o norequerible
    echo "=== TABLAS RELACIONADAS CON 'BLOQ' O 'NOREQUERIBLE' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%bloq%' OR table_name ILIKE '%noreq%' OR table_name ILIKE '%requerible%')
        AND table_type = 'BASE TABLE'
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }

        // Ver estructura de cada tabla encontrada
        foreach ($tables as $table) {
            $schema = $table['table_schema'];
            $tableName = $table['table_name'];

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

            // Ver datos de ejemplo
            echo "\n=== DATOS DE EJEMPLO (primeros 3 registros) ===\n";
            $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 3");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($rows) > 0) {
                foreach ($rows as $i => $row) {
                    echo "\nRegistro " . ($i + 1) . ":\n";
                    foreach ($row as $key => $value) {
                        echo "  $key: $value\n";
                    }
                }
            } else {
                echo "  (No hay datos en la tabla)\n";
            }
        }
    } else {
        echo "  (No se encontraron tablas relacionadas)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
