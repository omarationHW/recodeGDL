<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');

echo "Locales con energía vigencia='E' en oficina=5, mercado=1:\n\n";
$stmt = $pdo->query("
    SELECT a.id_local, a.oficina, a.num_mercado, a.vigencia as vig_local,
           e.id_energia, e.vigencia as vig_energia, e.cve_consumo, e.cantidad
    FROM publico.ta_11_locales a
    JOIN publico.ta_11_energia e ON a.id_local = e.id_local
    WHERE e.vigencia = 'E' AND a.oficina = 5 AND a.num_mercado = 1
");

foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo "  Local ID: {$row['id_local']}\n";
    echo "  Oficina: {$row['oficina']}, Mercado: {$row['num_mercado']}\n";
    echo "  Vigencia Local: {$row['vig_local']}\n";
    echo "  ID Energía: {$row['id_energia']}, Vigencia Energía: {$row['vig_energia']}\n";
    echo "  Clave Consumo: {$row['cve_consumo']}, Cantidad: {$row['cantidad']}\n\n";
}

// Probar el SP con vigencia más flexible
echo "\n=== Probando el SP con vigencia 'A' o 'E' ===\n";
$stmt2 = $pdo->query("
    SELECT COUNT(*) as total
    FROM publico.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN publico.ta_11_kilowhatts c ON c.axo = 2013 AND c.periodo = 6
    JOIN publico.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = 5
      AND a.num_mercado = 1
      AND a.vigencia = 'A'
      AND d.vigencia IN ('A', 'E')
");
echo "Total con vigencias A o E: " . $stmt2->fetch(PDO::FETCH_COLUMN) . "\n";
