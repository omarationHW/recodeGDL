<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');

echo "Verificando el JOIN con ta_11_mercados:\n\n";

echo "1. ¿Existe mercado con oficina=5, num_mercado_nvo=1?\n";
$stmt = $pdo->query("SELECT * FROM public.ta_11_mercados WHERE oficina = 5 AND num_mercado_nvo = 1");
$merc = $stmt->fetch(PDO::FETCH_ASSOC);
if ($merc) {
    echo "   SÍ: id_mercado={$merc['id_mercado']}, descripcion={$merc['descripcion']}\n\n";
} else {
    echo "   NO ENCONTRADO\n\n";
}

echo "2. Probando query sin el JOIN de ta_11_mercados:\n";
$stmt2 = $pdo->query("
    SELECT COUNT(*) as total
    FROM publico.ta_11_locales a
    JOIN publico.ta_11_kilowhatts c ON c.axo = 2013 AND c.periodo = 6
    JOIN publico.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = 5
      AND a.num_mercado = 1
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
");
echo "   Total SIN JOIN mercados: " . $stmt2->fetch(PDO::FETCH_COLUMN) . "\n\n";

echo "3. Ahora CON el JOIN de ta_11_mercados:\n";
$stmt3 = $pdo->query("
    SELECT COUNT(*) as total
    FROM publico.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN publico.ta_11_kilowhatts c ON c.axo = 2013 AND c.periodo = 6
    JOIN publico.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = 5
      AND a.num_mercado = 1
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
");
echo "   Total CON JOIN mercados: " . $stmt3->fetch(PDO::FETCH_COLUMN) . "\n\n";

// Si la diferencia es significativa, el problema está en el JOIN de mercados
echo "4. Verificando si los locales tienen un mercado correspondiente:\n";
$stmt4 = $pdo->query("
    SELECT a.id_local, a.oficina, a.num_mercado,
           CASE WHEN m.id_mercado IS NOT NULL THEN 'SÍ' ELSE 'NO' END as tiene_mercado
    FROM publico.ta_11_locales a
    LEFT JOIN public.ta_11_mercados m ON a.oficina = m.oficina AND a.num_mercado = m.num_mercado_nvo
    JOIN publico.ta_11_energia e ON a.id_local = e.id_local
    WHERE a.oficina = 5 AND a.num_mercado = 1 AND e.vigencia = 'E' AND a.vigencia = 'A'
");
foreach ($stmt4->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo "   Local {$row['id_local']} (oficina={$row['oficina']}, mercado={$row['num_mercado']}): Tiene mercado={$row['tiene_mercado']}\n";
}
