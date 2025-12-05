<?php
/**
 * Script para explorar la tabla req_mul_400 y obtener ejemplos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== EXPLORANDO TABLA req_mul_400 ===\n\n";

    // 1. Buscar la tabla en diferentes schemas
    echo "1. BUSCANDO TABLA req_mul_400 EN SCHEMAS:\n";
    $schemas = ['public', 'comun', 'comunX', 'db_ingresos', 'multas_reglamentos'];

    foreach ($schemas as $schema) {
        $check = $pdo->query("
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '$schema'
            AND table_name ILIKE '%req%mul%400%'
        ");

        $tables = $check->fetchAll(PDO::FETCH_COLUMN);
        if ($tables) {
            echo "  Schema $schema:\n";
            foreach ($tables as $table) {
                echo "    - $table\n";
            }
        }
    }

    // 2. Buscar tablas relacionadas con requerimientos
    echo "\n2. TABLAS RELACIONADAS CON REQUERIMIENTOS:\n";
    $relatedTables = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%req%'
        AND table_schema IN ('public', 'comun', 'comunX', 'db_ingresos')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    foreach ($relatedTables as $row) {
        echo "  {$row['table_schema']}.{$row['table_name']}\n";
    }

    // 3. Buscar datos en tabla req_mul_400 si existe
    echo "\n3. INTENTANDO OBTENER ESTRUCTURA DE req_mul_400:\n";

    foreach ($schemas as $schema) {
        try {
            $columns = $pdo->query("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = 'req_mul_400'
                ORDER BY ordinal_position
            ")->fetchAll(PDO::FETCH_ASSOC);

            if ($columns) {
                echo "  Encontrada en schema: $schema\n";
                echo "  Columnas:\n";
                foreach ($columns as $col) {
                    $type = $col['data_type'];
                    if ($col['character_maximum_length']) {
                        $type .= "({$col['character_maximum_length']})";
                    }
                    echo "    - {$col['column_name']}: $type\n";
                }

                // Obtener 3 ejemplos
                echo "\n  EJEMPLOS DE DATOS:\n";
                $examples = $pdo->query("SELECT * FROM $schema.req_mul_400 LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);

                foreach ($examples as $i => $row) {
                    echo "  Ejemplo " . ($i + 1) . ":\n";
                    foreach ($row as $key => $value) {
                        echo "    $key: " . (is_null($value) ? 'NULL' : $value) . "\n";
                    }
                    echo "\n";
                }

                // Contar registros
                $count = $pdo->query("SELECT COUNT(*) FROM $schema.req_mul_400")->fetchColumn();
                echo "  Total registros: $count\n\n";
            }
        } catch (Exception $e) {
            // Continuar con el siguiente schema
        }
    }

    // 4. Buscar en tablas alternativas
    echo "\n4. BUSCANDO EN TABLAS ALTERNATIVAS:\n";

    $alternativeTables = [
        'comun.multas_mpal_400',
        'comun.multas_fed_400',
        'comun.requerimientos',
        'public.requerimientos',
        'db_ingresos.req_multas',
        'public.req_multas'
    ];

    foreach ($alternativeTables as $fullTable) {
        try {
            $count = $pdo->query("SELECT COUNT(*) FROM $fullTable")->fetchColumn();
            echo "  $fullTable: $count registros\n";

            // Obtener columnas
            list($schema, $table) = explode('.', $fullTable);
            $columns = $pdo->query("
                SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$table'
                ORDER BY ordinal_position
            ")->fetchAll(PDO::FETCH_COLUMN);

            echo "    Columnas: " . implode(', ', $columns) . "\n";

            // Si tiene datos, mostrar ejemplos
            if ($count > 0) {
                $examples = $pdo->query("SELECT * FROM $fullTable LIMIT 1")->fetch(PDO::FETCH_ASSOC);
                echo "    Ejemplo:\n";
                foreach ($examples as $key => $value) {
                    echo "      $key: " . (is_null($value) ? 'NULL' : substr($value, 0, 50)) . "\n";
                }
            }
            echo "\n";
        } catch (Exception $e) {
            // Tabla no existe, continuar
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
