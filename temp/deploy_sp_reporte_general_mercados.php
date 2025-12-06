<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$sql = file_get_contents('C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\ReporteGeneralMercados_sp_reporte_general_mercados.sql');

try {
    $pdo->exec($sql);
    echo "✅ SP sp_reporte_general_mercados desplegado exitosamente\n\n";

    // Test with sample data
    echo "🧪 Probando SP con oficina 1, año 2010, periodo 1...\n\n";
    $stmt = $pdo->prepare('SELECT * FROM public.sp_reporte_general_mercados(?, ?, ?)');
    $stmt->execute([1, 2010, 1]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "Mercados encontrados: " . count($results) . "\n\n";
        echo sprintf("%-10s %-30s %12s %12s %15s\n", "Mercado", "Descripción", "Tot.Locales", "Loc.Pagos", "Importe Pagos");
        echo str_repeat("-", 85) . "\n";

        $total_pagos = 0;
        foreach (array_slice($results, 0, 5) as $r) {
            echo sprintf("%-10s %-30s %12s %12s $%14s\n",
                $r['num_mercado'],
                substr($r['descripcion'], 0, 28),
                number_format($r['total_locales']),
                number_format($r['locales_con_pagos']),
                number_format($r['importe_pagos'], 2)
            );
            $total_pagos += $r['importe_pagos'];
        }

        if (count($results) > 5) {
            echo "... (mostrando 5 de " . count($results) . " mercados)\n";
        }

        echo "\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
    } else {
        echo "⚠️  No se encontraron datos para los parámetros de prueba\n";
        echo "Esto es normal si no hay datos de enero 2010 en oficina 1\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
