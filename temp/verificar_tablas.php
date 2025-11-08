<?php
$pdo = new PDO('pgsql:host=localhost;port=5432;dbname=padron_licencias', 'postgres', 'postgres');

echo "Tablas en esquema 'comun' relacionadas con trámites/licencias:\n\n";

$stmt = $pdo->query("
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'comun'
    AND (tablename LIKE '%tramite%' OR tablename LIKE '%lic%')
    ORDER BY tablename
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  - comun.{$row['tablename']}\n";
}

echo "\n\nColumnas de comun.tramites:\n\n";
$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'tramites'
    ORDER BY ordinal_position
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  - {$row['column_name']} ({$row['data_type']})\n";
}
