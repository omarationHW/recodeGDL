<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🔍 Buscando tablas de energía en publico:\n\n";

$stmt = $pdo->query("
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'publico'
    AND table_name LIKE '%energ%'
    ORDER BY table_name
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  ✓ {$row['table_name']}\n";
}

echo "\n🔍 Buscando tablas con 'pag':\n\n";

$stmt = $pdo->query("
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'publico'
    AND table_name LIKE '%pag%'
    ORDER BY table_name
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  ✓ {$row['table_name']}\n";
}
?>
