<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "ESTRATEGIA 1: Analizar campos de ta_12_importes\n";
echo "================================================\n\n";

$sample = $pdo->query("SELECT * FROM public.ta_12_importes LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
echo "Campos disponibles:\n";
foreach (array_keys($sample[0]) as $col) {
    echo "  - $col\n";
}

echo "\n\nESTRATEGIA 2: Buscar tablas relacionadas con zonas\n";
echo "===================================================\n\n";

$tables = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('public', 'publico')
      AND (table_name LIKE '%zona%' OR table_name LIKE '%ingreso%' OR table_name LIKE '%import%')
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

if (count($tables) > 0) {
    echo "Tablas encontradas:\n";
    foreach ($tables as $t) {
        echo "  - {$t['table_schema']}.{$t['table_name']}\n";
    }
}

echo "\n\nESTRATEGIA 3: Analizar distribución de cta_aplicacion\n";
echo "=====================================================\n\n";

$cuentas = $pdo->query("
    SELECT
        cta_aplicacion,
        COUNT(*) as registros,
        SUM(importe_cta) as total_importe,
        MIN(fecing) as fecha_min,
        MAX(fecing) as fecha_max
    FROM public.ta_12_importes
    WHERE (cta_aplicacion BETWEEN 44501 AND 44588) OR (cta_aplicacion = 44119)
    GROUP BY cta_aplicacion
    ORDER BY cta_aplicacion
    LIMIT 20
")->fetchAll(PDO::FETCH_ASSOC);

echo "Top 20 cuentas más usadas:\n";
foreach ($cuentas as $c) {
    echo sprintf("  Cuenta %s: %s registros, $%s (desde %s hasta %s)\n",
        $c['cta_aplicacion'],
        number_format($c['registros']),
        number_format($c['total_importe'], 2),
        $c['fecha_min'],
        $c['fecha_max']
    );
}

echo "\n\nESTRATEGIA 4: Verificar si existe campo zona directamente en importes\n";
echo "=====================================================================\n\n";

$zona_fields = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'ta_12_importes'
      AND (column_name LIKE '%zona%' OR column_name LIKE '%mercado%' OR column_name LIKE '%local%')
")->fetchAll(PDO::FETCH_ASSOC);

if (count($zona_fields) > 0) {
    echo "Campos relacionados encontrados:\n";
    foreach ($zona_fields as $f) {
        echo "  - {$f['column_name']}: {$f['data_type']}\n";
    }
} else {
    echo "❌ No hay campos directos relacionados con zona, mercado o local\n";
}

echo "\n\nESTRATEGIA 5: Verificar si hay mapeo de cuentas\n";
echo "================================================\n\n";

$mapping_tables = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('public', 'publico')
      AND (table_name LIKE '%cuenta%' OR table_name LIKE '%catalogo%')
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

if (count($mapping_tables) > 0) {
    echo "Tablas de catálogo/mapeo:\n";
    foreach ($mapping_tables as $t) {
        echo "  - {$t['table_schema']}.{$t['table_name']}\n";
    }
}

echo "\n\nESTRATEGIA 6: Analizar estructura de ta_11_mercados\n";
echo "====================================================\n\n";

$mercados_fields = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'publico'
      AND table_name = 'ta_11_mercados'
    ORDER BY ordinal_position
")->fetchAll(PDO::FETCH_ASSOC);

echo "Campos de ta_11_mercados:\n";
foreach ($mercados_fields as $f) {
    echo "  - {$f['column_name']}: {$f['data_type']}\n";
}

echo "\n\nESTRATEGIA 7: Ver datos reales de mercados con zonas\n";
echo "=====================================================\n\n";

$mercados_zonas = $pdo->query("
    SELECT num_mercado_nvo, descripcion, id_zona, cuenta_ingreso, oficina
    FROM publico.ta_11_mercados
    WHERE id_zona IS NOT NULL
    ORDER BY id_zona, num_mercado_nvo
    LIMIT 15
")->fetchAll(PDO::FETCH_ASSOC);

if (count($mercados_zonas) > 0) {
    echo "Mercados con zonas asignadas:\n";
    foreach ($mercados_zonas as $m) {
        echo sprintf("  Zona %s: Mercado %s (%s) - Cuenta: %s, Oficina: %s\n",
            $m['id_zona'],
            $m['num_mercado_nvo'],
            $m['descripcion'],
            $m['cuenta_ingreso'],
            $m['oficina']
        );
    }
}
?>
