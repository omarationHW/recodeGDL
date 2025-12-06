<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Todas las tablas ta_12_* en schema public:\n\n";
$result = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'ta_12%' ORDER BY table_name")->fetchAll(PDO::FETCH_COLUMN);
foreach ($result as $table) {
    echo "  - $table\n";
}
echo "\n\nBuscando tablas especificas en todos los esquemas:\n";
$tables = ['ta_12_ingreso', 'ta_12_zonas', 'ta_12_ajustes'];
foreach ($tables as $table) {
    echo "\n$table:\n";
    $result = $pdo->query("SELECT table_schema FROM information_schema.tables WHERE table_name = '$table' ORDER BY table_schema")->fetchAll(PDO::FETCH_COLUMN);
    if (count($result) > 0) {
        foreach ($result as $schema) {
            echo "  ✅ $schema\n";
        }
    } else {
        echo "  ❌ No existe en ningún esquema\n";
    }
}
?>
