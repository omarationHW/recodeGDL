<?php
/**
 * Script para verificar la estructura de la tabla descmultampal
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE LA TABLA descmultampal ===\n\n";

    // Obtener estructura de la tabla
    $columns = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'descmultampal'
        ORDER BY ordinal_position
    ")->fetchAll(PDO::FETCH_ASSOC);

    echo "Columnas disponibles:\n";
    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length} [{$col['is_nullable']}]\n";
    }
    echo "\n";

    // Obtener algunos ejemplos de datos
    echo "Ejemplos de datos (primeros 3 registros):\n";
    echo str_repeat("=", 80) . "\n";

    $examples = $pdo->query("
        SELECT *
        FROM catastro_gdl.descmultampal
        LIMIT 3
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($examples as $idx => $row) {
        echo "\nREGISTRO " . ($idx + 1) . ":\n";
        foreach ($row as $key => $value) {
            if ($value !== null && trim($value) !== '') {
                echo "  $key: " . trim($value) . "\n";
            }
        }
    }

    // Contar registros totales
    $total = $pdo->query("SELECT COUNT(*) FROM catastro_gdl.descmultampal")->fetchColumn();
    echo "\n\nTotal de registros en la tabla: $total\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
