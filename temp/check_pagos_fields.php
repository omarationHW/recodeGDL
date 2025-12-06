<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "Columnas de publico.ta_11_pagos_local:\n\n";

$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'publico' AND table_name = 'ta_11_pagos_local'
    ORDER BY ordinal_position
");

foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
    echo "  {$col['column_name']} ({$col['data_type']})\n";
}
?>
