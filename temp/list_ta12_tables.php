<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Todas las tablas ta_12_* en schema publico:\n\n";
$result = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'publico' AND table_name LIKE 'ta_12%' ORDER BY table_name")->fetchAll(PDO::FETCH_COLUMN);
foreach ($result as $table) {
    echo "  - $table\n";
}
?>
