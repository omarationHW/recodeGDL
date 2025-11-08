<?php
$pdo = new PDO('pgsql:host=localhost;port=5432;dbname=padron_licencias', 'postgres', 'postgres');

echo "Buscando tabla 'tramites' en todos los esquemas:\n\n";

$stmt = $pdo->query("
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE tablename = 'tramites'
    ORDER BY schemaname
");

$found = false;
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  ✓ {$row['schemaname']}.{$row['tablename']}\n";
    $found = true;
}

if (!$found) {
    echo "  ✗ No se encontró la tabla 'tramites'\n";
}

echo "\n\nBuscando tabla 'lic_autoev' en todos los esquemas:\n\n";

$stmt = $pdo->query("
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE tablename = 'lic_autoev'
    ORDER BY schemaname
");

$found = false;
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  ✓ {$row['schemaname']}.{$row['tablename']}\n";
    $found = true;
}

if (!$found) {
    echo "  ✗ No se encontró la tabla 'lic_autoev'\n";
}

echo "\n\nTodos los esquemas disponibles:\n\n";
$stmt = $pdo->query("
    SELECT nspname
    FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname != 'information_schema'
    ORDER BY nspname
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  - {$row['nspname']}\n";
}
