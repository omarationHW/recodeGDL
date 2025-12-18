<?php
// Script para buscar tablas de cuentas o catastro

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas de cuentas
    echo "=== TABLAS RELACIONADAS CON 'CUENTA' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%cuenta%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico', 'catastro_gdl')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Ver la tabla catastro_gdl si existe
    echo "\n\n=== VERIFICANDO ESQUEMA catastro_gdl ===\n";
    $stmt = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'catastro_gdl'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
        LIMIT 10
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($tables) > 0) {
        echo "Tablas en catastro_gdl:\n";
        foreach ($tables as $table) {
            echo "  - $table\n";
        }

        // Ver estructura de la primera tabla que parezca principal
        foreach ($tables as $table) {
            if ($table == 'cuentas' || $table == 'predios' || stripos($table, 'cuenta') !== false) {
                echo "\n=== ESTRUCTURA DE catastro_gdl.{$table} ===\n";
                $stmt = $pdo->query("
                    SELECT column_name, data_type, character_maximum_length
                    FROM information_schema.columns
                    WHERE table_schema = 'catastro_gdl'
                    AND table_name = '$table'
                    ORDER BY ordinal_position
                    LIMIT 20
                ");
                $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
                }

                echo "\nDatos de ejemplo:\n";
                try {
                    $stmt = $pdo->query("SELECT * FROM catastro_gdl.{$table} LIMIT 2");
                    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    if (count($rows) > 0) {
                        $keys = array_slice(array_keys($rows[0]), 0, 6);
                        foreach ($rows as $i => $row) {
                            echo "  Reg " . ($i + 1) . ": ";
                            foreach ($keys as $key) {
                                $val = is_null($row[$key]) ? 'NULL' : substr(trim($row[$key]), 0, 15);
                                echo "$key=$val ";
                            }
                            echo "\n";
                        }
                    }
                } catch (Exception $e) {
                    echo "  Error: " . $e->getMessage() . "\n";
                }

                break; // Solo mostrar la primera tabla relevante
            }
        }
    } else {
        echo "  (No hay tablas en catastro_gdl)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
