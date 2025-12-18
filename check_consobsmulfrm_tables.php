<?php
// Script para buscar tablas relacionadas con observaciones de multas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el contenido del stored procedure existente
    echo "=== CONTENIDO DEL STORED PROCEDURE recaudadora_consobsmulfrm ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_consobsmulfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo substr($result['definition'], 0, 1000) . "...\n";
    } else {
        echo "  (No se encontró el stored procedure)\n";
    }

    // Buscar tablas relacionadas con observaciones o multas
    echo "\n\n=== TABLAS RELACIONADAS CON 'OBSERVACION' O 'OBS' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%observ%' OR table_name ILIKE '%obs%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }

        // Ver detalles de tablas relevantes
        foreach ($tables as $table) {
            $schema = $table['table_schema'];
            $tableName = $table['table_name'];

            if (stripos($tableName, 'multa') !== false ||
                $tableName == 'observaciones' ||
                stripos($tableName, 'obs') === 0) {

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
                echo "\nDatos de ejemplo (2 registros):\n";
                try {
                    $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 2");
                    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                    if (count($rows) > 0) {
                        foreach ($rows as $i => $row) {
                            echo "  Registro " . ($i + 1) . ": ";
                            $keys = array_slice(array_keys($row), 0, 6);
                            foreach ($keys as $key) {
                                $val = is_null($row[$key]) ? 'NULL' : substr($row[$key], 0, 30);
                                echo "$key=$val ";
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
