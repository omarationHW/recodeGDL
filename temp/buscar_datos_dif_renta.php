<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando datos para spd_11_dif_renta ===\n\n";

    // Buscar pagos que tengan diferencia de renta
    $sql = "
        SELECT
            a.id_pago_local,
            a.id_local,
            a.axo,
            a.periodo,
            a.fecha_pago,
            a.oficina_pago,
            a.caja_pago,
            a.operacion_pago,
            a.importe_pago,
            a.folio,
            b.oficina,
            b.num_mercado,
            b.categoria,
            b.seccion,
            b.local,
            b.letra_local,
            b.superficie,
            b.clave_cuota,
            cu.importe_cuota,
            (CASE
                WHEN b.seccion = 'PS' AND b.clave_cuota = 4 THEN b.superficie * cu.importe_cuota
                WHEN b.seccion = 'PS' THEN (cu.importe_cuota * b.superficie) * 30
                ELSE b.superficie * cu.importe_cuota
            END) AS renta_esperada,
            a.importe_pago - (CASE
                WHEN b.seccion = 'PS' AND b.clave_cuota = 4 THEN b.superficie * cu.importe_cuota
                WHEN b.seccion = 'PS' THEN (cu.importe_cuota * b.superficie) * 30
                ELSE b.superficie * cu.importe_cuota
            END) AS diferencia
        FROM publico.ta_11_pagos_local a
        JOIN publico.ta_11_locales b ON b.id_local = a.id_local
        JOIN public.ta_11_mercados c ON c.oficina = b.oficina AND c.num_mercado_nvo = b.num_mercado
        JOIN publico.ta_11_cuo_locales cu ON cu.axo = a.axo AND cu.categoria = b.categoria AND cu.seccion = b.seccion AND cu.clave_cuota = b.clave_cuota
        WHERE a.fecha_pago BETWEEN '2024-01-01' AND '2025-12-31'
          AND a.importe_pago <> (CASE
                WHEN b.seccion = 'PS' AND b.clave_cuota = 4 THEN b.superficie * cu.importe_cuota
                WHEN b.seccion = 'PS' THEN (cu.importe_cuota * b.superficie) * 30
                ELSE b.superficie * cu.importe_cuota
            END)
        ORDER BY a.fecha_pago DESC
        LIMIT 10
    ";

    $stmt = $pdo->query($sql);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "✓ Encontrados " . count($results) . " pagos con diferencia de renta:\n\n";

        foreach ($results as $i => $row) {
            echo "Registro #" . ($i + 1) . ":\n";
            echo "  ID Pago Local: {$row['id_pago_local']}\n";
            echo "  ID Local: {$row['id_local']}\n";
            echo "  Fecha Pago: {$row['fecha_pago']}\n";
            echo "  Oficina: {$row['oficina']}\n";
            echo "  Local: {$row['oficina']}-{$row['num_mercado']}-{$row['local']}{$row['letra_local']}\n";
            echo "  Sección: {$row['seccion']}\n";
            echo "  Clave Cuota: {$row['clave_cuota']}\n";
            echo "  Superficie: {$row['superficie']}\n";
            echo "  Importe Cuota: \${$row['importe_cuota']}\n";
            echo "  Importe Pagado: \${$row['importe_pago']}\n";
            echo "  Renta Esperada: \${$row['renta_esperada']}\n";
            echo "  Diferencia: \${$row['diferencia']}\n";
            echo "\n";
        }

        // Mostrar combinación de parámetros para probar el SP
        $primera = $results[0];
        echo "=== Parámetros para probar el SP ===\n";
        echo "Oficina: {$primera['oficina']}\n";
        echo "Fecha Desde: {$primera['fecha_pago']}\n";
        echo "Fecha Hasta: 2025-12-31\n";
        echo "\nComando SQL:\n";
        echo "SELECT * FROM spd_11_dif_renta({$primera['oficina']}, '{$primera['fecha_pago']}', '2025-12-31');\n";

    } else {
        echo "No se encontraron pagos con diferencia de renta.\n";
        echo "Buscando datos alternativos...\n\n";

        // Buscar pagos recientes
        $sql2 = "
            SELECT DISTINCT c.oficina, MIN(a.fecha_pago) as fecha_desde, MAX(a.fecha_pago) as fecha_hasta, COUNT(*) as total_pagos
            FROM publico.ta_11_pagos_local a
            JOIN publico.ta_11_locales b ON b.id_local = a.id_local
            JOIN public.ta_11_mercados c ON c.oficina = b.oficina AND c.num_mercado_nvo = b.num_mercado
            WHERE a.fecha_pago >= '2024-01-01'
            GROUP BY c.oficina
            ORDER BY total_pagos DESC
            LIMIT 5
        ";

        $stmt2 = $pdo->query($sql2);
        $stats = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        echo "Estadísticas de pagos por oficina:\n\n";
        foreach ($stats as $stat) {
            echo "Oficina: {$stat['oficina']}\n";
            echo "  Total Pagos: {$stat['total_pagos']}\n";
            echo "  Fecha Desde: {$stat['fecha_desde']}\n";
            echo "  Fecha Hasta: {$stat['fecha_hasta']}\n";
            echo "  Comando: SELECT * FROM spd_11_dif_renta({$stat['oficina']}, '{$stat['fecha_desde']}', '{$stat['fecha_hasta']}');\n\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
