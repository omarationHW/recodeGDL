<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "=== Buscando tablas de adeudos ===\n\n";

$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%adeudo%'
       OR table_name LIKE '%deuda%'
    ORDER BY table_schema, table_name
");

foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo "{$row['table_schema']}.{$row['table_name']}\n";
}

echo "\n=== Buscando tablas ta_11 en db_ingresos ===\n\n";

$stmt = $pdo->query("
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'db_ingresos'
      AND table_name LIKE 'ta_11%'
    ORDER BY table_name
");

foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo "db_ingresos.{$row['table_name']}\n";
}
