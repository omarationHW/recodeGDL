<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
echo "Buscando tablas ta_12_recaudadoras en todos los schemas:\n\n";
$stmt = $pdo->query("
    SELECT
        schemaname,
        tablename
    FROM pg_tables
    WHERE tablename = 'ta_12_recaudadoras'
    ORDER BY schemaname
");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $table) {
    $schema = $table['schemaname'];
    echo "═══════════════════════════════════════════════════════════════\n";
    echo "Schema: $schema\n";
    echo "═══════════════════════════════════════════════════════════════\n";
    $stmt2 = $pdo->query("SELECT COUNT(*) as total FROM $schema.ta_12_recaudadoras");
    $count = $stmt2->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: {$count['total']}\n\n";
    $stmt3 = $pdo->query("SELECT id_rec, recaudadora FROM $schema.ta_12_recaudadoras ORDER BY id_rec LIMIT 10");
    $rows = $stmt3->fetchAll(PDO::FETCH_ASSOC);
    echo "Primeros 10 registros:\n";
    foreach ($rows as $row) {
        echo "  {$row['id_rec']}: {$row['recaudadora']}\n";
    }
    echo "\n";
}
