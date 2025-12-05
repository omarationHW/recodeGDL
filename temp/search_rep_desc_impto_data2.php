<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== EXPLORANDO ESTRUCTURAS DE TABLAS DE DESCUENTOS ===\n\n";

// Ver estructura de descpredial
echo "1. ESTRUCTURA DE comun.descpredial:\n";
$stmt1 = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'descpredial'
    ORDER BY ordinal_position
");
$cols1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols1 as $c) {
    echo "  {$c['column_name']} ({$c['data_type']})\n";
}

// Obtener muestra de datos
echo "\n\n2. MUESTRA DE DATOS EN comun.descpredial:\n";
$stmt2 = $pdo->query("SELECT * FROM comun.descpredial LIMIT 5");
$muestra = $stmt2->fetchAll(PDO::FETCH_ASSOC);
foreach ($muestra as $m) {
    echo "  " . json_encode($m) . "\n";
}

// Buscar en ta_12_descuentos
echo "\n\n3. ESTRUCTURA DE comun.ta_12_descuentos:\n";
try {
    $stmt3 = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_12_descuentos'
        ORDER BY ordinal_position
    ");
    $cols3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols3 as $c) {
        echo "  {$c['column_name']} ({$c['data_type']})\n";
    }

    echo "\n  MUESTRA DE DATOS:\n";
    $stmt3b = $pdo->query("SELECT * FROM comun.ta_12_descuentos LIMIT 5");
    $muestra3 = $stmt3b->fetchAll(PDO::FETCH_ASSOC);
    foreach ($muestra3 as $m) {
        echo "    " . json_encode($m) . "\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Buscar en c_descmulta
echo "\n\n4. ESTRUCTURA DE comun.c_descmulta:\n";
try {
    $stmt4 = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'c_descmulta'
        ORDER BY ordinal_position
    ");
    $cols4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols4 as $c) {
        echo "  {$c['column_name']} ({$c['data_type']})\n";
    }

    echo "\n  MUESTRA DE DATOS:\n";
    $stmt4b = $pdo->query("SELECT * FROM comun.c_descmulta LIMIT 10");
    $muestra4 = $stmt4b->fetchAll(PDO::FETCH_ASSOC);
    foreach ($muestra4 as $m) {
        echo "    " . json_encode($m) . "\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Buscar en parametros_desctransmisones
echo "\n\n5. ESTRUCTURA DE comun.parametros_desctransmisones:\n";
try {
    $stmt5 = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'parametros_desctransmisones'
        ORDER BY ordinal_position
    ");
    $cols5 = $stmt5->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols5 as $c) {
        echo "  {$c['column_name']} ({$c['data_type']})\n";
    }

    echo "\n  MUESTRA DE DATOS:\n";
    $stmt5b = $pdo->query("SELECT * FROM comun.parametros_desctransmisones LIMIT 5");
    $muestra5 = $stmt5b->fetchAll(PDO::FETCH_ASSOC);
    foreach ($muestra5 as $m) {
        echo "    " . json_encode($m) . "\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

// Buscar datos de multas con descuentos aplicados
echo "\n\n6. MULTAS CON DESCUENTOS (comun.multas):\n";
try {
    $stmt6 = $pdo->query("
        SELECT
            EXTRACT(YEAR FROM fecha_acta) as axo,
            COUNT(*) as total_multas,
            COUNT(CASE WHEN descuento > 0 THEN 1 END) as con_descuento,
            SUM(descuento) as suma_descuentos
        FROM comun.multas
        WHERE fecha_acta >= '2020-01-01'
        AND fecha_acta < '2026-01-01'
        GROUP BY EXTRACT(YEAR FROM fecha_acta)
        ORDER BY axo DESC
    ");
    $multas_desc = $stmt6->fetchAll(PDO::FETCH_ASSOC);
    foreach ($multas_desc as $m) {
        echo "  Año: {$m['axo']} | Total: {$m['total_multas']} | Con desc: {$m['con_descuento']} | Suma: \${$m['suma_descuentos']}\n";
    }
} catch (Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}

?>
