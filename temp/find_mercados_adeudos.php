<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');

echo '=== Verificando tablas en base mercados ===\n\n';

// Verificar ta_11_localpaso
$stmt = $pdo->query("SELECT COUNT(*) as total FROM public.ta_11_localpaso WHERE vigencia = 'A'");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
echo "Locales activos (ta_11_localpaso): {$row['total']}\n";

// Verificar ta_11_adeudo_local
$stmt = $pdo->query("SELECT COUNT(*) as total FROM public.ta_11_adeudo_local");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
echo "Adeudos (ta_11_adeudo_local): {$row['total']}\n\n";

// Buscar combinaciones válidas
echo '=== Buscando combinaciones válidas ===\n\n';
$stmt = $pdo->query("
    SELECT
        l.oficina,
        a.axo,
        a.periodo,
        COUNT(*) as total_adeudos
    FROM public.ta_11_adeudo_local a
    INNER JOIN public.ta_11_localpaso l ON a.id_local = l.id_local
    WHERE l.vigencia = 'A'
      AND a.axo >= 2020
    GROUP BY l.oficina, a.axo, a.periodo
    ORDER BY a.axo DESC, a.periodo DESC, total_adeudos DESC
    LIMIT 10
");

echo "Combinaciones disponibles:\n";
echo str_repeat('-', 60) . "\n";
printf("%-10s %-10s %-10s %-15s\n", 'Oficina', 'Año', 'Periodo', 'Total Adeudos');
echo str_repeat('-', 60) . "\n";

$combos = $stmt->fetchAll(PDO::FETCH_ASSOC);
$first = null;
foreach ($combos as $combo) {
    printf("%-10s %-10s %-10s %-15s\n",
        $combo['oficina'],
        $combo['axo'],
        $combo['periodo'],
        $combo['total_adeudos']
    );
    if (!$first) $first = $combo;
}

if ($first) {
    echo "\n" . str_repeat('=', 60) . "\n";
    echo "✓ RECOMENDACIÓN:\n";
    echo str_repeat('=', 60) . "\n";
    echo "Oficina: {$first['oficina']}\n";
    echo "Año: {$first['axo']}\n";
    echo "Periodo: {$first['periodo']}\n";
    echo "Total de registros: {$first['total_adeudos']}\n";
}

?>
