<?php
// Script para verificar estructura de ta_11_cuo_locales

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Verificando estructura de ta_11_cuo_locales...\n\n";

    // Obtener estructura de la tabla
    $sql = "
        SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
        FROM information_schema.columns
        WHERE table_name = 'ta_11_cuo_locales'
        AND table_schema IN ('public', 'comun', 'comunX', 'db_ingresos', 'catastro_gdl')
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
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
            echo "{$col['column_name']}: {$type}\n";
        }
    } else {
        echo "No se encontró la tabla ta_11_cuo_locales\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
