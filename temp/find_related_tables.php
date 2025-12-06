<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Buscando tablas relacionadas con ingreso, zonas y ajustes:\n\n";
$patterns = ['%ingreso%', '%zona%', '%ajuste%'];
foreach ($patterns as $pattern) {
    echo "Patron: $pattern\n";
    $result = $pdo->query("SELECT table_schema, table_name FROM information_schema.tables WHERE table_name LIKE '$pattern' AND table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_name")->fetchAll(PDO::FETCH_ASSOC);
    if (count($result) > 0) {
        foreach ($result as $r) {
            echo "  - {$r['table_schema']}.{$r['table_name']}\n";
        }
    } else {
        echo "  (ninguna)\n";
    }
    echo "\n";
}
?>
