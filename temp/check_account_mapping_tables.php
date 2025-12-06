<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "TABLA 1: ta_cuentastrans\n";
echo "========================\n\n";

$exists = $pdo->query("SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ta_cuentastrans' AND table_schema = 'public')")->fetchColumn();

if ($exists) {
    $structure = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'ta_cuentastrans'
        ORDER BY ordinal_position
    ")->fetchAll(PDO::FETCH_ASSOC);

    echo "Estructura:\n";
    foreach ($structure as $col) {
        echo "  - {$col['column_name']}: {$col['data_type']}\n";
    }

    $count = $pdo->query("SELECT COUNT(*) as total FROM public.ta_cuentastrans")->fetch();
    echo "\nTotal registros: " . number_format($count['total']) . "\n\n";

    $sample = $pdo->query("SELECT * FROM public.ta_cuentastrans LIMIT 10")->fetchAll(PDO::FETCH_ASSOC);
    echo "Muestra de datos:\n";
    foreach ($sample as $i => $row) {
        echo "  " . ($i+1) . ". ";
        foreach ($row as $k => $v) {
            echo "$k=$v ";
        }
        echo "\n";
    }

    echo "\nBuscando coincidencias con cuentas de importes (445XX):\n";
    $match = $pdo->query("
        SELECT *
        FROM public.ta_cuentastrans
        WHERE EXISTS (
            SELECT 1 FROM public.ta_12_importes i
            WHERE i.cta_aplicacion::TEXT = ANY(ARRAY[
                ta_cuentastrans::TEXT
            ])
        )
        LIMIT 5
    ");
    // Try different column matches

} else {
    echo "❌ Tabla no existe\n";
}

echo "\n\nTABLA 2: ta_11_catalogo_dif\n";
echo "===========================\n\n";

$structure = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema IN ('public', 'publico') AND table_name = 'ta_11_catalogo_dif'
    ORDER BY ordinal_position
")->fetchAll(PDO::FETCH_ASSOC);

if (count($structure) > 0) {
    echo "Estructura:\n";
    foreach ($structure as $col) {
        echo "  - {$col['column_name']}: {$col['data_type']}\n";
    }

    $count = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_catalogo_dif")->fetch();
    echo "\nTotal registros: " . number_format($count['total']) . "\n\n";

    $sample = $pdo->query("SELECT * FROM publico.ta_11_catalogo_dif LIMIT 10")->fetchAll(PDO::FETCH_ASSOC);
    echo "Muestra de datos:\n";
    foreach ($sample as $i => $row) {
        echo "  " . ($i+1) . ". ";
        foreach ($row as $k => $v) {
            echo "$k=" . (is_null($v) ? 'NULL' : $v) . " ";
        }
        echo "\n";
    }
}

echo "\n\nTABLA 3: Buscar otras tablas de catálogo\n";
echo "=========================================\n\n";

$catalog_tables = $pdo->query("
    SELECT table_schema, table_name,
           (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name) as num_cols
    FROM information_schema.tables t
    WHERE table_schema IN ('public', 'publico')
      AND (table_name LIKE 'ta_11%' OR table_name LIKE 'ta_12%')
      AND table_name NOT LIKE '%_old%'
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

echo "Tablas disponibles (ta_11*, ta_12*):\n";
foreach ($catalog_tables as $t) {
    echo "  - {$t['table_schema']}.{$t['table_name']} ({$t['num_cols']} columnas)\n";
}

echo "\n\nESTRATEGIA ALTERNATIVA: Mapeo por último dígito\n";
echo "================================================\n\n";
echo "Analizando si los últimos 2 dígitos de cta_aplicacion (445XX)\n";
echo "corresponden al num_mercado_nvo:\n\n";

$test_mapping = $pdo->query("
    SELECT
        i.cta_aplicacion,
        COUNT(*) as registros,
        SUM(i.importe_cta) as total_importe
    FROM public.ta_12_importes i
    WHERE (i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119)
    GROUP BY i.cta_aplicacion
    ORDER BY i.cta_aplicacion
    LIMIT 20
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($test_mapping as $map) {
    $ultimos_digitos = substr($map['cta_aplicacion'], -2);
    $num_mercado = intval($ultimos_digitos);

    // Check if this mercado exists
    $mercado = $pdo->query("SELECT num_mercado_nvo, descripcion, id_zona FROM publico.ta_11_mercados WHERE num_mercado_nvo = $num_mercado")->fetch();

    if ($mercado) {
        echo sprintf("  Cuenta %s -> Mercado %s (%s) ZONA %s: %s registros, $%s\n",
            $map['cta_aplicacion'],
            $mercado['num_mercado_nvo'],
            $mercado['descripcion'],
            $mercado['id_zona'] ?? 'NULL',
            number_format($map['registros']),
            number_format($map['total_importe'], 2)
        );
    } else {
        echo sprintf("  Cuenta %s -> Mercado %s: NO EXISTE\n",
            $map['cta_aplicacion'],
            $num_mercado
        );
    }
}
?>
