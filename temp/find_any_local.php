<?php
// Script para buscar CUALQUIER tabla de locales

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS DE LOCALES ===\n\n";

    // Buscar todas las tablas que contengan 'local' en su nombre
    $schemaQuery = "
        SELECT
            table_schema,
            table_name,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE columns.table_schema = tables.table_schema
             AND columns.table_name = tables.table_name) as column_count
        FROM information_schema.tables
        WHERE table_name ILIKE '%local%'
        AND table_schema NOT IN ('information_schema', 'pg_catalog')
        ORDER BY table_schema, table_name
    ";

    $tables = $pdo->query($schemaQuery)->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas encontradas con 'local': " . count($tables) . "\n\n";

    foreach ($tables as $table) {
        $fullTable = $table['table_schema'] . '.' . $table['table_name'];
        echo "Probando: $fullTable (columnas: {$table['column_count']})\n";

        try {
            $countQuery = "SELECT COUNT(*) as total FROM $fullTable";
            $count = $pdo->query($countQuery)->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0) {
                echo "  ✓ TIENE DATOS: {$count['total']} registros\n";

                // Obtener columnas
                $colQuery = "
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = '{$table['table_schema']}'
                    AND table_name = '{$table['table_name']}'
                    ORDER BY ordinal_position
                ";
                $cols = $pdo->query($colQuery)->fetchAll(PDO::FETCH_COLUMN);

                echo "  Columnas: " . implode(', ', $cols) . "\n";

                // Obtener primer registro
                $dataQuery = "SELECT * FROM $fullTable LIMIT 1";
                $record = $pdo->query($dataQuery)->fetch(PDO::FETCH_ASSOC);

                if ($record) {
                    echo "\n  PRIMER REGISTRO:\n";
                    foreach ($record as $col => $val) {
                        $displayVal = $val ?? 'NULL';
                        if (strlen($displayVal) > 50) {
                            $displayVal = substr($displayVal, 0, 50) . '...';
                        }
                        echo "    $col: $displayVal\n";
                    }
                }

                echo "\n";
            }
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n";
        }
    }

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
}
