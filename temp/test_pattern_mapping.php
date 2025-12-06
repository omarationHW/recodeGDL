<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "ESTRATEGIA: Mapeo por últimos 2 dígitos\n";
echo "========================================\n\n";
echo "Hipótesis: cta_aplicacion 445XX -> mercado XX\n";
echo "Ejemplo: 44501 -> mercado 1, 44502 -> mercado 2, etc.\n\n";

$test_mapping = $pdo->query("
    SELECT
        i.cta_aplicacion,
        COUNT(*) as registros,
        SUM(i.importe_cta) as total_importe
    FROM public.ta_12_importes i
    WHERE (i.cta_aplicacion BETWEEN 44501 AND 44520) OR (i.cta_aplicacion = 44119)
    GROUP BY i.cta_aplicacion
    ORDER BY i.cta_aplicacion
")->fetchAll(PDO::FETCH_ASSOC);

$matched = 0;
$unmatched = 0;
$total_matched_amount = 0;

foreach ($test_mapping as $map) {
    if ($map['cta_aplicacion'] == 44119) {
        echo sprintf("  Cuenta %s (ESPECIAL): %s registros, $%s - REQUIERE REVISIÓN\n",
            $map['cta_aplicacion'],
            number_format($map['registros']),
            number_format($map['total_importe'], 2)
        );
        continue;
    }

    $ultimos_digitos = substr($map['cta_aplicacion'], -2);
    $num_mercado = intval($ultimos_digitos);

    // Check if this mercado exists
    $mercado = $pdo->query("SELECT num_mercado_nvo, descripcion, id_zona FROM publico.ta_11_mercados WHERE num_mercado_nvo = $num_mercado")->fetch();

    if ($mercado) {
        echo sprintf("  ✅ Cuenta %s -> Mercado %s (%s) ZONA %s: %s registros, $%s\n",
            $map['cta_aplicacion'],
            $mercado['num_mercado_nvo'],
            substr($mercado['descripcion'], 0, 25),
            $mercado['id_zona'] ?? 'NULL',
            number_format($map['registros']),
            number_format($map['total_importe'], 2)
        );
        $matched++;
        $total_matched_amount += $map['total_importe'];
    } else {
        echo sprintf("  ❌ Cuenta %s -> Mercado %s: NO EXISTE\n",
            $map['cta_aplicacion'],
            $num_mercado
        );
        $unmatched++;
    }
}

echo "\n\nRESUMEN:\n";
echo "  ✅ Coincidencias encontradas: $matched\n";
echo "  ❌ Sin coincidencia: $unmatched\n";
echo "  💰 Monto total con zona asignada: $" . number_format($total_matched_amount, 2) . "\n";

if ($matched > 0) {
    echo "\n✅ ¡PATRÓN VÁLIDO! El mapeo funciona.\n";
    echo "\nAhora vamos a probar con TODO el rango (44501-44588):\n\n";

    $full_test = $pdo->query("
        SELECT
            SUBSTRING(i.cta_aplicacion::TEXT, 4)::INTEGER AS num_mercado_calculado,
            COUNT(*) as total_registros,
            SUM(i.importe_cta) as total_importe,
            COUNT(DISTINCT m.id_zona) as zonas_encontradas
        FROM public.ta_12_importes i
        LEFT JOIN publico.ta_11_mercados m ON SUBSTRING(i.cta_aplicacion::TEXT, 4)::INTEGER = m.num_mercado_nvo
        WHERE (i.cta_aplicacion BETWEEN 44501 AND 44588)
        GROUP BY SUBSTRING(i.cta_aplicacion::TEXT, 4)::INTEGER
        HAVING COUNT(*) > 0
        ORDER BY total_registros DESC
        LIMIT 10
    ")->fetchAll(PDO::FETCH_ASSOC);

    echo "Top 10 mercados con más registros:\n";
    foreach ($full_test as $ft) {
        echo sprintf("  Mercado %s: %s registros, $%s, %s zona(s)\n",
            $ft['num_mercado_calculado'],
            number_format($ft['total_registros']),
            number_format($ft['total_importe'], 2),
            $ft['zonas_encontradas']
        );
    }
}
?>
