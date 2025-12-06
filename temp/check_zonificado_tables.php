<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Buscando tablas mencionadas en el SP:\n\n";
$tables = ['ta_12_ingreso', 'ta_12_importes', 'ta_11_mercados', 'ta_12_zonas', 'ta_12_ajustes'];
foreach ($tables as $table) {
    $result = $pdo->query("SELECT table_schema, table_name FROM information_schema.tables WHERE table_name = '$table' AND table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema")->fetchAll(PDO::FETCH_ASSOC);
    if (count($result) > 0) {
        echo "✅ $table:\n";
        foreach ($result as $r) {
            echo "   - {$r['table_schema']}.{$r['table_name']}\n";
        }
    } else {
        echo "❌ $table: NO ENCONTRADA\n";
    }
    echo "\n";
}
?>
