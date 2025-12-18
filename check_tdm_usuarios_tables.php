<?php
// Script para buscar tablas relacionadas con tdm_usuarios

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas relacionadas con tdm o usuarios
    echo "=== TABLAS RELACIONADAS CON 'TDM' O 'USUARIOS' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%tdm%' OR table_name ILIKE '%usuario%' OR table_name ILIKE '%user%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }

        // Ver estructura de cada tabla relacionada con tdm
        foreach ($tables as $table) {
            $schema = $table['table_schema'];
            $tableName = $table['table_name'];

            if (stripos($tableName, 'tdm') === false) {
                continue; // Solo mostrar tablas con 'tdm' en el nombre
            }

            echo "\n=== ESTRUCTURA DE {$schema}.{$tableName} ===\n";
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$tableName'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
                echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
            }

            // Ver datos de ejemplo
            echo "\n=== DATOS DE EJEMPLO (primeros 3 registros) ===\n";
            try {
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 3");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                if (count($rows) > 0) {
                    foreach ($rows as $i => $row) {
                        echo "\nRegistro " . ($i + 1) . ":\n";
                        foreach ($row as $key => $value) {
                            if ($key == 'clave' || $key == 'password' || $key == 'passwd') {
                                echo "  $key: ***\n";
                            } else {
                                $displayValue = is_null($value) ? 'NULL' : (strlen($value) > 100 ? substr($value, 0, 100) . "..." : $value);
                                echo "  $key: $displayValue\n";
                            }
                        }
                    }
                } else {
                    echo "  (No hay datos en la tabla)\n";
                }
            } catch (Exception $e) {
                echo "  Error al leer datos: " . $e->getMessage() . "\n";
            }
        }
    } else {
        echo "  (No se encontraron tablas relacionadas)\n";
    }

    // Ver el contenido del stored procedure existente
    echo "\n\n=== CONTENIDO DEL STORED PROCEDURE recaudadora_tdm_conection ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_tdm_conection'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n";
    } else {
        echo "  (No se encontró el stored procedure)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
