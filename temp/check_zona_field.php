<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Verificando si ta_11_mercados tiene campo id_zona:\n\n";
$result = $pdo->query("SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'publico' AND table_name = 'ta_11_mercados' AND column_name LIKE '%zona%'")->fetchAll(PDO::FETCH_ASSOC);
if (count($result) > 0) {
    foreach ($result as $r) {
        echo "  ✅ {$r['column_name']}: {$r['data_type']}\n";
    }
} else {
    echo "  ❌ No hay campos relacionados con zona\n";
}

echo "\n\nBuscando datos de ejemplo en ta_12_importes:\n";
$sample = $pdo->query("SELECT * FROM public.ta_12_importes LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);
if (count($sample) > 0) {
    echo "  Columnas: " . implode(', ', array_keys($sample[0])) . "\n";
    echo "  Total registros: " . $pdo->query('SELECT COUNT(*) as total FROM public.ta_12_importes')->fetch()['total'] . "\n";
}
?>
