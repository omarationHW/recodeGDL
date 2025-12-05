<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== REPORTE DE DESCUENTOS POR EJERCICIO ===\n\n";

// Ver columnas relevantes de multas
echo "1. COLUMNAS RELEVANTES DE comun.multas:\n";
$cols = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun' AND table_name = 'multas'
    AND (column_name LIKE '%desc%' OR column_name LIKE '%axo%' OR column_name LIKE '%ejerc%')
    ORDER BY ordinal_position
")->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) {
    echo "  {$c['column_name']} ({$c['data_type']})\n";
}

// Datos por año (usando axo_acta como ejercicio)
echo "\n\n2. MULTAS POR EJERCICIO (axo_acta):\n";
$ejercicios = $pdo->query("
    SELECT
        axo_acta as ejercicio,
        COUNT(*) as total_multas,
        SUM(multa) as suma_multas,
        SUM(gastos) as suma_gastos,
        SUM(total) as suma_total
    FROM comun.multas
    WHERE axo_acta BETWEEN 2020 AND 2025
    GROUP BY axo_acta
    ORDER BY axo_acta DESC
")->fetchAll(PDO::FETCH_ASSOC);
foreach ($ejercicios as $e) {
    echo "  Ejercicio: {$e['ejercicio']} | Multas: {$e['total_multas']} | Total: \${$e['suma_total']}\n";
}

// Detalle por dependencia para cada ejercicio
echo "\n\n3. DETALLE POR DEPENDENCIA - EJERCICIO 2025:\n";
$det2025 = $pdo->query("
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
        SUM(multa) as total_multas,
        SUM(gastos) as total_gastos,
        SUM(total) as total_general
    FROM comun.multas
    WHERE axo_acta = 2025
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
")->fetchAll(PDO::FETCH_ASSOC);
$total2025 = 0;
foreach ($det2025 as $d) {
    echo "  {$d['nombre_dependencia']}: {$d['cantidad_multas']} multas - \${$d['total_general']}\n";
    $total2025 += $d['cantidad_multas'];
}
echo "  TOTAL 2025: $total2025 multas\n";

// Detalle 2024
echo "\n\n4. DETALLE POR DEPENDENCIA - EJERCICIO 2024:\n";
$det2024 = $pdo->query("
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
        SUM(multa) as total_multas,
        SUM(gastos) as total_gastos,
        SUM(total) as total_general
    FROM comun.multas
    WHERE axo_acta = 2024
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
")->fetchAll(PDO::FETCH_ASSOC);
$total2024 = 0;
foreach ($det2024 as $d) {
    echo "  {$d['nombre_dependencia']}: {$d['cantidad_multas']} multas - \${$d['total_general']}\n";
    $total2024 += $d['cantidad_multas'];
}
echo "  TOTAL 2024: $total2024 multas\n";

// Detalle 2023
echo "\n\n5. DETALLE POR DEPENDENCIA - EJERCICIO 2023:\n";
$det2023 = $pdo->query("
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
        SUM(multa) as total_multas,
        SUM(gastos) as total_gastos,
        SUM(total) as total_general
    FROM comun.multas
    WHERE axo_acta = 2023
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
")->fetchAll(PDO::FETCH_ASSOC);
$total2023 = 0;
foreach ($det2023 as $d) {
    echo "  {$d['nombre_dependencia']}: {$d['cantidad_multas']} multas - \${$d['total_general']}\n";
    $total2023 += $d['cantidad_multas'];
}
echo "  TOTAL 2023: $total2023 multas\n";

echo "\n\n=== 3 EJEMPLOS PARA EL FORMULARIO ===\n\n";
echo "EJEMPLO 1: Ejercicio 2025\n";
echo "  Total de multas: $total2025\n";
echo "  Dependencias: " . count($det2025) . "\n\n";

echo "EJEMPLO 2: Ejercicio 2024\n";
echo "  Total de multas: $total2024\n";
echo "  Dependencias: " . count($det2024) . "\n\n";

echo "EJEMPLO 3: Ejercicio 2023\n";
echo "  Total de multas: $total2023\n";
echo "  Dependencias: " . count($det2023) . "\n\n";
?>
