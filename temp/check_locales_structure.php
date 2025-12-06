<?php
// Script para verificar estructura de ta_11_locales

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Buscando tabla ta_11_locales...\n\n";

    // Buscar la tabla en diferentes schemas
    $sql = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'ta_11_locales'
        ORDER BY table_schema
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tabla encontrada en los siguientes schemas:\n";
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
        echo "\n";

        // Verificar estructura del schema comun
        echo "Estructura de comun.ta_11_locales:\n";

        $sql = "
            SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
            FROM information_schema.columns
            WHERE table_name = 'ta_11_locales'
            AND table_schema = 'comun'
            ORDER BY ordinal_position
        ";

        $stmt = $pdo->query($sql);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            } elseif ($col['numeric_precision']) {
                $type .= "({$col['numeric_precision']}";
                if ($col['numeric_scale']) {
                    $type .= ",{$col['numeric_scale']}";
                }
                $type .= ")";
            }
            echo "  {$col['column_name']}: {$type}\n";
        }

    } else {
        echo "No se encontró la tabla ta_11_locales\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
