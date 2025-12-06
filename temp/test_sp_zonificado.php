<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "Verificando datos en ta_12_importes:\n\n";

$dateRange = $pdo->query("SELECT MIN(fecing) as min_fecha, MAX(fecing) as max_fecha, COUNT(*) as total FROM public.ta_12_importes")->fetch(PDO::FETCH_ASSOC);
echo "Rango de fechas: {$dateRange['min_fecha']} a {$dateRange['max_fecha']}\n";
echo "Total registros: " . number_format($dateRange['total']) . "\n\n";

echo "Probando SP con rango real...\n";
$stmt = $pdo->prepare('SELECT * FROM sp_ingreso_zonificado(?, ?)');
$stmt->execute(['2004-01-01', '2025-12-31']);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Zonas encontradas: " . count($results) . "\n\n";

if (count($results) > 0) {
    echo "Resultados:\n";
    $total = 0;
    foreach ($results as $r) {
        echo "  - Zona {$r['id_zona']}: {$r['zona']} = $" . number_format($r['pagado'], 2) . "\n";
        $total += $r['pagado'];
    }
    echo "\nTotal general: $" . number_format($total, 2) . "\n";
}
?>
