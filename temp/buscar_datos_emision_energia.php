<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando datos para get_emision_energia ===\n\n";

// Buscar combinaciones válidas
$sql = "
    SELECT
        a.oficina,
        a.num_mercado,
        COUNT(DISTINCT a.id_local) as total_locales,
        COUNT(DISTINCT d.id_energia) as total_energia
    FROM publico.ta_11_locales a
    JOIN publico.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.vigencia = 'A' AND d.vigencia = 'E'
    GROUP BY a.oficina, a.num_mercado
    HAVING COUNT(DISTINCT a.id_local) > 0
    ORDER BY total_locales DESC
    LIMIT 5
";

$stmt = $pdo->query($sql);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($results) > 0) {
    echo "Combinaciones válidas de oficina-mercado con energía:\n\n";
    foreach ($results as $i => $row) {
        echo "Opción " . ($i + 1) . ":\n";
        echo "  Oficina: {$row['oficina']}\n";
        echo "  Mercado: {$row['num_mercado']}\n";
        echo "  Total Locales: {$row['total_locales']}\n";
        echo "  Total Registros Energía: {$row['total_energia']}\n";
        echo "\n";
    }

    // Buscar años y periodos disponibles en kilowhatts
    echo "\n=== Años y periodos disponibles en ta_11_kilowhatts ===\n\n";
    $stmt2 = $pdo->query("SELECT DISTINCT axo, periodo FROM publico.ta_11_kilowhatts ORDER BY axo DESC, periodo DESC LIMIT 10");
    $periodos = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($periodos as $p) {
        echo "Año: {$p['axo']}, Período: {$p['periodo']}\n";
    }

    // Sugerir comando de prueba
    $primera = $results[0];
    $primer_periodo = $periodos[0] ?? ['axo' => 2025, 'periodo' => 1];
    echo "\n=== Comando de prueba sugerido ===\n";
    echo "SELECT * FROM get_emision_energia({$primera['oficina']}, {$primera['num_mercado']}, {$primer_periodo['axo']}, {$primer_periodo['periodo']});\n";
} else {
    echo "No se encontraron datos válidos\n";
}
