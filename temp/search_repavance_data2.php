<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== BUSCANDO DATOS VÁLIDOS PARA REPORTE DE AVANCE ===\n\n";

// Filtrar solo fechas válidas (entre 2000 y 2030)
echo "1. DATOS EN AGOSTO 2025:\n";
$stmt1 = $pdo->query("
    SELECT
        id_dependencia,
        COUNT(*) as cantidad,
        SUM(total) as monto,
        MIN(fecha_acta) as fecha_min,
        MAX(fecha_acta) as fecha_max
    FROM comun.multas
    WHERE fecha_acta >= '2025-08-01'
    AND fecha_acta < '2025-09-01'
    AND fecha_acta IS NOT NULL
    GROUP BY id_dependencia
    ORDER BY cantidad DESC
");
$agosto = $stmt1->fetchAll(PDO::FETCH_ASSOC);
$total_agosto = 0;
foreach ($agosto as $a) {
    echo "  Dep {$a['id_dependencia']}: {$a['cantidad']} multas - \${$a['monto']}\n";
    $total_agosto += $a['cantidad'];
}
echo "  TOTAL AGOSTO: $total_agosto multas\n";

// Primer rango
echo "\n\n2. RANGO 1: Primera semana de Agosto 2025 (1-7)\n";
$stmt2 = $pdo->query("
    SELECT
        id_dependencia,
        CASE id_dependencia
            WHEN 1 THEN 'TESORERIA'
            WHEN 3 THEN 'TRANSITO'
            WHEN 4 THEN 'MERCADOS'
            WHEN 5 THEN 'OBRAS PUBLICAS'
            WHEN 6 THEN 'DESARROLLO URBANO'
            WHEN 7 THEN 'REGLAMENTOS'
            WHEN 8 THEN 'RASTRO'
            WHEN 25 THEN 'ATENCION CIUDADANA'
            WHEN 35 THEN 'ECOLOGIA'
            ELSE 'OTRAS'
        END as nombre_dependencia,
        COUNT(*) as cantidad_multas,
        SUM(multa) as total_multas,
        SUM(gastos) as total_gastos,
        SUM(total) as total_general
    FROM comun.multas
    WHERE fecha_acta >= '2025-08-01'
    AND fecha_acta <= '2025-08-07'
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
");
$rango1 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
$total1 = 0;
foreach ($rango1 as $r) {
    echo "  {$r['nombre_dependencia']}: {$r['cantidad_multas']} multas - \${$r['total_general']}\n";
    $total1 += $r['cantidad_multas'];
}
echo "  TOTAL: $total1 multas\n";

// Segundo rango
echo "\n\n3. RANGO 2: Segunda semana de Agosto 2025 (8-14)\n";
$stmt3 = $pdo->query("
    SELECT
        id_dependencia,
        CASE id_dependencia
            WHEN 1 THEN 'TESORERIA'
            WHEN 3 THEN 'TRANSITO'
            WHEN 5 THEN 'OBRAS PUBLICAS'
            WHEN 7 THEN 'REGLAMENTOS'
            WHEN 35 THEN 'ECOLOGIA'
            ELSE 'OTRAS'
        END as nombre_dependencia,
        COUNT(*) as cantidad_multas,
        SUM(total) as total_general
    FROM comun.multas
    WHERE fecha_acta >= '2025-08-08'
    AND fecha_acta <= '2025-08-14'
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
");
$rango2 = $stmt3->fetchAll(PDO::FETCH_ASSOC);
$total2 = 0;
foreach ($rango2 as $r) {
    echo "  {$r['nombre_dependencia']}: {$r['cantidad_multas']} multas - \${$r['total_general']}\n";
    $total2 += $r['cantidad_multas'];
}
echo "  TOTAL: $total2 multas\n";

// Tercer rango
echo "\n\n4. RANGO 3: Tercera semana de Agosto 2025 (15-21)\n";
$stmt4 = $pdo->query("
    SELECT
        id_dependencia,
        CASE id_dependencia
            WHEN 1 THEN 'TESORERIA'
            WHEN 3 THEN 'TRANSITO'
            WHEN 5 THEN 'OBRAS PUBLICAS'
            WHEN 7 THEN 'REGLAMENTOS'
            WHEN 35 THEN 'ECOLOGIA'
            ELSE 'OTRAS'
        END as nombre_dependencia,
        COUNT(*) as cantidad_multas,
        SUM(total) as total_general
    FROM comun.multas
    WHERE fecha_acta >= '2025-08-15'
    AND fecha_acta <= '2025-08-21'
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
");
$rango3 = $stmt4->fetchAll(PDO::FETCH_ASSOC);
$total3 = 0;
foreach ($rango3 as $r) {
    echo "  {$r['nombre_dependencia']}: {$r['cantidad_multas']} multas - \${$r['total_general']}\n";
    $total3 += $r['cantidad_multas'];
}
echo "  TOTAL: $total3 multas\n";

echo "\n\n=== 3 EJEMPLOS PARA EL FORMULARIO ===\n\n";

echo "EJEMPLO 1: Primera semana de Agosto 2025\n";
echo "  Desde: 2025-08-01\n";
echo "  Hasta: 2025-08-07\n";
echo "  Dependencias: " . count($rango1) . "\n";
echo "  Total multas: $total1\n\n";

echo "EJEMPLO 2: Segunda semana de Agosto 2025\n";
echo "  Desde: 2025-08-08\n";
echo "  Hasta: 2025-08-14\n";
echo "  Dependencias: " . count($rango2) . "\n";
echo "  Total multas: $total2\n\n";

echo "EJEMPLO 3: Tercera semana de Agosto 2025\n";
echo "  Desde: 2025-08-15\n";
echo "  Hasta: 2025-08-21\n";
echo "  Dependencias: " . count($rango3) . "\n";
echo "  Total multas: $total3\n\n";
?>
