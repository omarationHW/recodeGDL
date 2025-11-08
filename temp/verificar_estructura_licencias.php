<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Verificando estructura de comun.licencias:\n\n";

// Ver columnas de la tabla
$stmt = $pdo->query("
    SELECT column_name, data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'licencias'
    ORDER BY ordinal_position
");

$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Columnas de comun.licencias:\n";
foreach ($columns as $col) {
    $maxlen = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
    echo "  - {$col['column_name']}: {$col['data_type']}{$maxlen}\n";
}

// Ver un registro de ejemplo
echo "\n\nRegistro de ejemplo (Licencia 490593):\n";
$stmt = $pdo->query("SELECT * FROM comun.licencias WHERE licencia = 490593 LIMIT 1");
$ejemplo = $stmt->fetch(PDO::FETCH_ASSOC);

if ($ejemplo) {
    foreach ($ejemplo as $key => $value) {
        $display_value = $value ?? 'NULL';
        if (is_string($display_value) && strlen($display_value) > 50) {
            $display_value = substr($display_value, 0, 50) . '...';
        }
        echo "  {$key}: {$display_value}\n";
    }
} else {
    echo "  No se encontró el registro\n";
}
