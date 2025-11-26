<?php
/**
 * Ver estructura de la tabla reqdiftransmision
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "🔍 Estructura de catastro_gdl.reqdiftransmision\n\n";

    $sql = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'reqdiftransmision'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
        echo "Columnas encontradas:\n\n";
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "(" . $col['character_maximum_length'] . ")";
            }
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            echo "  - {$col['column_name']}: {$type} {$nullable}\n";
        }
    }

    // Ver algunos registros de ejemplo
    echo "\n\n📊 Registros de ejemplo (primeros 3):\n\n";

    $sql = "SELECT * FROM catastro_gdl.reqdiftransmision LIMIT 3";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $idx => $row) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
