<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "=== Combinaciones con locales activos ===\n\n";

$stmt = $pdo->query("
    SELECT
        l.oficina,
        l.num_mercado,
        m.descripcion,
        COUNT(*) as total_locales
    FROM comun.ta_11_locales l
    JOIN comun.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    WHERE l.vigencia = 'A'
    GROUP BY l.oficina, l.num_mercado, m.descripcion
    HAVING COUNT(*) > 5
    ORDER BY COUNT(*) DESC
    LIMIT 10
");

foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo "Oficina: {$row['oficina']} | Mercado: {$row['num_mercado']} | {$row['descripcion']} | Locales: {$row['total_locales']}\n";
}
