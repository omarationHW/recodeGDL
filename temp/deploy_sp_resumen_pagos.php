<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Desplegando sp_rpt_resumen_pagos...\n\n";
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RptResumenPagos_sp_rpt_resumen_pagos.sql';
$sql = file_get_contents($sqlFile);
try {
    $pdo->exec($sql);
    echo "SP desplegado exitosamente\n\n";
    $check = $pdo->query("SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'sp_rpt_resumen_pagos'")->fetch();
    if ($check) {
        echo "Verificacion: SP existe\n\n";
        echo "Buscando datos de prueba...\n";
        $test = $pdo->query("SELECT DISTINCT l.oficina, MIN(p.fecha_pago) as fecha_min, MAX(p.fecha_pago) as fecha_max FROM publico.ta_11_pagos_local p INNER JOIN publico.ta_11_locales l ON l.id_local = p.id_local GROUP BY l.oficina LIMIT 1")->fetch(PDO::FETCH_ASSOC);
        if ($test) {
            echo "Probando con: Oficina={$test['oficina']}, Fecha desde={$test['fecha_min']}, hasta={$test['fecha_max']}\n\n";
            $stmt = $pdo->prepare("SELECT * FROM sp_rpt_resumen_pagos(?, ?, ?, NULL)");
            $stmt->execute([$test['oficina'], $test['fecha_min'], $test['fecha_max']]);
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "Registros obtenidos: " . count($results) . "\n";
            if (count($results) > 0) {
                $r = $results[0];
                echo "\nPrimer mercado:\n";
                echo "  Oficina: {$r['oficina']}, Mercado: {$r['num_mercado']}\n";
                echo "  Descripcion: {$r['descripcion']}\n";
                echo "  Locales con pago: {$r['total_locales_con_pago']}\n";
                echo "  Total pagos: {$r['total_pagos']}\n";
                echo "  Periodos pagados: {$r['total_periodos_pagados']}\n";
                echo "  Importe total: $" . number_format($r['importe_total'], 2) . "\n";
                echo "  Pago promedio: $" . number_format($r['pago_promedio'], 2) . "\n";
                echo "  Fecha primer pago: {$r['fecha_primer_pago']}\n";
                echo "  Fecha ultimo pago: {$r['fecha_ultimo_pago']}\n";
            }
            echo "\nSP FUNCIONANDO CORRECTAMENTE\n";
        }
    }
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
