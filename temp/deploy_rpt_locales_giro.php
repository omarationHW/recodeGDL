<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$sql = file_get_contents('C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\RptLocalesGiro_sp_rpt_locales_giro.sql');

try {
    $pdo->exec($sql);
    echo "✅ SP sp_rpt_locales_giro desplegado exitosamente\n\n";

    // Test with sample data
    echo "🧪 Probando SP con oficina 1...\n\n";
    $stmt = $pdo->prepare('SELECT * FROM public.sp_rpt_locales_giro(?, NULL, NULL)');
    $stmt->execute([1]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "Locales encontrados: " . count($results) . "\n\n";
        echo sprintf("%-10s %-10s %-10s %-20s %-15s %12s\n", "Mercado", "Giro", "Local", "Nombre", "Desc. Giro", "Superficie");
        echo str_repeat("-", 90) . "\n";

        foreach (array_slice($results, 0, 10) as $r) {
            echo sprintf("%-10s %-10s %-10s %-20s %-15s %12s\n",
                $r['num_mercado'],
                $r['giro'] ?? 'NULL',
                $r['local'],
                substr($r['nombre'] ?? 'N/A', 0, 18),
                substr($r['descripcion_giro'] ?? 'N/A', 0, 13),
                number_format($r['superficie'], 2)
            );
        }

        if (count($results) > 10) {
            echo "... (mostrando 10 de " . count($results) . " locales)\n";
        }

        // Agrupar por giro
        echo "\n📊 Estadísticas por giro:\n";
        $giros_stats = [];
        foreach ($results as $r) {
            $giro = $r['giro'] ?? 0;
            if (!isset($giros_stats[$giro])) {
                $giros_stats[$giro] = [
                    'count' => 0,
                    'superficie_total' => 0,
                    'descripcion' => $r['descripcion_giro']
                ];
            }
            $giros_stats[$giro]['count']++;
            $giros_stats[$giro]['superficie_total'] += $r['superficie'];
        }

        ksort($giros_stats);
        foreach (array_slice($giros_stats, 0, 10, true) as $giro => $stats) {
            echo sprintf("  • %s: %d locales, %.2f m² total\n",
                $stats['descripcion'],
                $stats['count'],
                $stats['superficie_total']
            );
        }

        echo "\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
    } else {
        echo "⚠️  No se encontraron locales activos para oficina 1\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
