<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== ESTRUCTURA DE comun.multas ===\n\n";
$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'multas'
    ORDER BY ordinal_position
");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) {
    echo "{$c['column_name']}: {$c['data_type']}\n";
}

echo "\n\n=== EJEMPLO DE REGISTRO ===\n\n";
$stmt2 = $pdo->query("SELECT * FROM comun.multas LIMIT 1");
$ejemplo = $stmt2->fetch(PDO::FETCH_ASSOC);
echo json_encode($ejemplo, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
