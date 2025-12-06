<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "=== Tablas relacionadas con pagos ===\n\n";

$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%pago%'
    ORDER BY table_schema, table_name
");

foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo "{$row['table_schema']}.{$row['table_name']}\n";
}
