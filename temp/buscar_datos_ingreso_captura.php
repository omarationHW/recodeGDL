<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando combinaciones de filtros con datos ===\n\n";

// Buscar las combinaciones más populares
$sql = "
    SELECT
        a.num_mercado,
        DATE_TRUNC('month', b.fecha_pago)::DATE as mes_pago,
        b.oficina_pago,
        b.caja_pago,
        b.operacion_pago,
        COUNT(*) as total_pagos,
        SUM(b.importe_pago) as total_importe,
        MIN(b.fecha_pago) as fecha_min,
        MAX(b.fecha_pago) as fecha_max,
        COUNT(DISTINCT b.fecha_pago) as dias_con_pagos
    FROM publico.ta_11_locales a
    JOIN publico.ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE b.fecha_pago >= '2024-01-01'
    GROUP BY a.num_mercado, DATE_TRUNC('month', b.fecha_pago), b.oficina_pago, b.caja_pago, b.operacion_pago
    HAVING COUNT(*) >= 5
    ORDER BY total_pagos DESC, total_importe DESC
    LIMIT 10
";

$stmt = $pdo->query($sql);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($results) > 0) {
    echo "Encontradas " . count($results) . " combinaciones con múltiples pagos:\n\n";

    foreach ($results as $i => $row) {
        echo "Opción " . ($i + 1) . ":\n";
        echo "  Mercado: {$row['num_mercado']}\n";
        echo "  Mes: {$row['mes_pago']}\n";
        echo "  Oficina Pago: {$row['oficina_pago']}\n";
        echo "  Caja: '{$row['caja_pago']}'\n";
        echo "  Operación: {$row['operacion_pago']}\n";
        echo "  Total Pagos: {$row['total_pagos']}\n";
        echo "  Total Importe: \${$row['total_importe']}\n";
        echo "  Rango fechas: {$row['fecha_min']} a {$row['fecha_max']}\n";
        echo "  Días con pagos: {$row['dias_con_pagos']}\n";
        echo "\n";
    }

    // Probar con la primera opción
    $primera = $results[0];
    echo "\n=== Probando con la opción más popular ===\n\n";

    echo "Parámetros:\n";
    echo "  p_num_mercado: {$primera['num_mercado']}\n";
    echo "  p_fecha_pago: {$primera['fecha_min']}\n";
    echo "  p_oficina_pago: {$primera['oficina_pago']}\n";
    echo "  p_caja_pago: '{$primera['caja_pago']}'\n";
    echo "  p_operacion_pago: {$primera['operacion_pago']}\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM sp_get_ingreso_captura(?, ?, ?, ?, ?)");
    $stmt2->execute([
        $primera['num_mercado'],
        $primera['fecha_min'],
        $primera['oficina_pago'],
        $primera['caja_pago'],
        $primera['operacion_pago']
    ]);
    $results_sp = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados del SP:\n";
    echo "  Total registros: " . count($results_sp) . "\n\n";

    foreach ($results_sp as $j => $result) {
        echo "  Día " . ($j + 1) . ":\n";
        echo "    Fecha: {$result['fecha_pago']}\n";
        echo "    Caja: '{$result['caja_pago']}'\n";
        echo "    Operación: {$result['operacion_pago']}\n";
        echo "    Pagos: {$result['pagos']}\n";
        echo "    Importe: \${$result['importe']}\n";
        echo "\n";
    }

    // Estadísticas
    $total_dias = count($results_sp);
    $total_pagos_sp = array_sum(array_column($results_sp, 'pagos'));
    $total_importe_sp = array_sum(array_column($results_sp, 'importe'));

    echo "Resumen:\n";
    echo "  Total días con pagos: {$total_dias}\n";
    echo "  Total pagos en el mes: {$total_pagos_sp}\n";
    echo "  Total importe: \${$total_importe_sp}\n";

} else {
    echo "No se encontraron combinaciones con datos suficientes\n";

    // Buscar cualquier dato disponible
    echo "\nBuscando cualquier dato disponible...\n\n";
    $stmt = $pdo->query("
        SELECT
            a.num_mercado,
            b.fecha_pago,
            b.oficina_pago,
            b.caja_pago,
            b.operacion_pago,
            COUNT(*) as total
        FROM publico.ta_11_locales a
        JOIN publico.ta_11_pagos_local b ON a.id_local = b.id_local
        GROUP BY a.num_mercado, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago
        ORDER BY b.fecha_pago DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "Mercado: {$row['num_mercado']}, Fecha: {$row['fecha_pago']}, Oficina: {$row['oficina_pago']}, Caja: '{$row['caja_pago']}', Op: {$row['operacion_pago']}, Total: {$row['total']}\n";
    }
}
