<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Verificando estructura de comun.tramites:\n\n";

// Ver columnas de la tabla
$stmt = $pdo->query("
    SELECT column_name, data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'tramites'
    ORDER BY ordinal_position
");

$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Columnas de comun.tramites:\n";
foreach ($columns as $col) {
    $maxlen = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
    echo "  - {$col['column_name']}: {$col['data_type']}{$maxlen}\n";
}

// Ver un registro de ejemplo
echo "\n\nRegistro de ejemplo (ID 349786):\n";
$stmt = $pdo->query("SELECT * FROM comun.tramites WHERE id_tramite = 349786 LIMIT 1");
$ejemplo = $stmt->fetch(PDO::FETCH_ASSOC);

if ($ejemplo) {
    foreach ($ejemplo as $key => $value) {
        echo "  {$key}: " . ($value ?? 'NULL') . "\n";
    }
} else {
    echo "  No se encontró el registro\n";
}
