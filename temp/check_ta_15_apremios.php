<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🔍 Buscando tabla ta_15_apremios:\n\n";

$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%apremios%' OR table_name LIKE '%ta_15%'
    ORDER BY table_schema, table_name
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  • {$row['table_schema']}.{$row['table_name']}\n";
}
?>
