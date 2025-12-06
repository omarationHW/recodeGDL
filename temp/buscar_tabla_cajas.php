<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando tabla de cajas ===\n\n";

// Buscar tablas que contengan "caja" en el nombre
$sql = "
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%caja%'
    AND table_schema IN ('public', 'publico')
    ORDER BY table_schema, table_name
";

$stmt = $pdo->query($sql);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($tables) > 0) {
    echo "Tablas encontradas con 'caja':\n";
    foreach ($tables as $table) {
        echo "  {$table['table_schema']}.{$table['table_name']}\n";
    }
    echo "\n";
}

// Buscar en ta_12_importes que tiene cajing
echo "=== Verificando ta_12_importes (tiene campo cajing) ===\n\n";
$stmt2 = $pdo->query("
    SELECT table_schema FROM information_schema.tables
    WHERE table_name = 'ta_12_importes'
");
$schema = $stmt2->fetch(PDO::FETCH_COLUMN);

if ($schema) {
    echo "Tabla encontrada en schema: {$schema}\n\n";

    // Ver estructura
    echo "Estructura de la tabla:\n";
    $stmt3 = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = '{$schema}' AND table_name = 'ta_12_importes'
        ORDER BY ordinal_position
    ");
    foreach ($stmt3->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "  {$col['column_name']}: {$type}\n";
    }

    echo "\n";

    // Buscar la caja ZF
    echo "Buscando información de la caja 'ZF':\n\n";
    $stmt4 = $pdo->query("
        SELECT DISTINCT cajing, recing, COUNT(*) as registros
        FROM {$schema}.ta_12_importes
        WHERE cajing = 'ZF'
        GROUP BY cajing, recing
    ");

    $cajas = $stmt4->fetchAll(PDO::FETCH_ASSOC);
    if (count($cajas) > 0) {
        foreach ($cajas as $caja) {
            echo "  Caja: '{$caja['cajing']}'\n";
            echo "  Recaudadora: {$caja['recing']}\n";
            echo "  Total registros: {$caja['registros']}\n\n";
        }
    } else {
        echo "  No se encontró la caja 'ZF' en ta_12_importes\n\n";
    }

    // Listar todas las cajas disponibles
    echo "Todas las cajas disponibles:\n\n";
    $stmt5 = $pdo->query("
        SELECT DISTINCT cajing, COUNT(DISTINCT recing) as recaudadoras, COUNT(*) as total_ops
        FROM {$schema}.ta_12_importes
        GROUP BY cajing
        ORDER BY cajing
        LIMIT 20
    ");

    foreach ($stmt5->fetchAll(PDO::FETCH_ASSOC) as $caja) {
        echo "  Caja '{$caja['cajing']}': {$caja['recaudadoras']} recaudadora(s), {$caja['total_ops']} operaciones\n";
    }
}

// Verificar en ta_11_pagos_local qué cajas se usan
echo "\n\n=== Cajas usadas en pagos (ta_11_pagos_local) ===\n\n";
$stmt6 = $pdo->query("
    SELECT DISTINCT caja_pago, COUNT(*) as total_pagos
    FROM publico.ta_11_pagos_local
    GROUP BY caja_pago
    ORDER BY total_pagos DESC
    LIMIT 20
");

echo "Cajas más usadas en pagos:\n";
foreach ($stmt6->fetchAll(PDO::FETCH_ASSOC) as $caja) {
    echo "  Caja '{$caja['caja_pago']}': {$caja['total_pagos']} pagos\n";
}
