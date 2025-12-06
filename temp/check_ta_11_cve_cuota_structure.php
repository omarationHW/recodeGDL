<?php
// Script para verificar estructura de ta_11_cve_cuota

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Buscando tabla ta_11_cve_cuota...\n\n";

    // Buscar la tabla en diferentes schemas
    $sql = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'ta_11_cve_cuota'
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

        // Verificar estructura de la primera tabla encontrada
        $firstSchema = $tables[0]['table_schema'];
        echo "Estructura de {$firstSchema}.ta_11_cve_cuota:\n";

        $sql = "
            SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
            FROM information_schema.columns
            WHERE table_name = 'ta_11_cve_cuota'
            AND table_schema = '$firstSchema'
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

        // Verificar si el SP existe
        echo "\n\nVerificando si el SP existe:\n";
        $sql = "
            SELECT proname, pronamespace::regnamespace as schema
            FROM pg_proc
            WHERE proname = 'sp_get_claves_cuota'
        ";
        $stmt = $pdo->query($sql);
        $sp = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($sp) {
            echo "✓ SP existe en schema: {$sp['schema']}\n";
        } else {
            echo "✗ SP no existe en la base de datos\n";
        }

    } else {
        echo "No se encontró la tabla ta_11_cve_cuota\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
