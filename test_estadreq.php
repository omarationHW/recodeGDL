<?php
// Script para probar el stored procedure recaudadora_estadreq actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_estadreq...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_estadreq.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin parámetros (estadísticas generales)
    echo "2. Probando estadísticas generales (sin filtros)...\n";
    $stmt = $pdo->query("SELECT * FROM publico.recaudadora_estadreq('')");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total de grupos encontrados: " . count($rows) . "\n\n";

    if (count($rows) > 0) {
        echo "   Top 10 por volumen de requerimientos:\n";
        for ($i = 0; $i < min(10, count($rows)); $i++) {
            $r = $rows[$i];
            echo "\n   " . ($i + 1) . ". {$r['ejecutor']} - {$r['recaudadora']}\n";
            echo "      Total requerimientos: " . number_format($r['total_requerimientos']) . "\n";
            echo "      Entregados: " . number_format($r['entregados']) . "\n";
            echo "      Pendientes: " . number_format($r['pendientes']) . "\n";
            echo "      Vencidos: " . number_format($r['vencidos']) . "\n";
            echo "      Cancelados: " . number_format($r['cancelados']) . "\n";
            echo "      Monto total: $" . number_format($r['monto_total'], 2) . "\n";
        }
    }

    // 3. Buscar por ejecutor específico
    echo "\n\n3. Probando búsqueda por ejecutor 'SANCHEZ'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_estadreq(?)");
    $stmt->execute(['SANCHEZ']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " ejecutor(es) encontrado(s)\n";
    if (count($rows) > 0) {
        foreach ($rows as $r) {
            echo "\n   - {$r['ejecutor']} ({$r['recaudadora']})\n";
            echo "     Total: " . number_format($r['total_requerimientos']) . " requerimientos\n";
            echo "     Pendientes: " . number_format($r['pendientes']) . ", Entregados: " . number_format($r['entregados']) . "\n";
        }
    }

    // 4. Estadísticas por recaudadora
    echo "\n\n4. Totales por recaudadora...\n";
    $stmt = $pdo->query("
        SELECT
            recaudadora,
            SUM(total_requerimientos) AS total,
            SUM(entregados) AS entregados,
            SUM(pendientes) AS pendientes,
            SUM(vencidos) AS vencidos,
            SUM(cancelados) AS cancelados,
            SUM(monto_total) AS monto
        FROM publico.recaudadora_estadreq('')
        GROUP BY recaudadora
        ORDER BY total DESC
    ");
    $recaudadoras = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($recaudadoras as $rec) {
        echo "\n   {$rec['recaudadora']}:\n";
        echo "     Total requerimientos: " . number_format($rec['total']) . "\n";
        echo "     Entregados: " . number_format($rec['entregados']) . " (" . round($rec['entregados']/$rec['total']*100, 1) . "%)\n";
        echo "     Pendientes: " . number_format($rec['pendientes']) . " (" . round($rec['pendientes']/$rec['total']*100, 1) . "%)\n";
        echo "     Vencidos: " . number_format($rec['vencidos']) . " (" . round($rec['vencidos']/$rec['total']*100, 1) . "%)\n";
        echo "     Cancelados: " . number_format($rec['cancelados']) . " (" . round($rec['cancelados']/$rec['total']*100, 1) . "%)\n";
        echo "     Monto total: $" . number_format($rec['monto'], 2) . "\n";
    }

    // 5. Estadísticas globales
    echo "\n\n5. Estadísticas globales del sistema...\n";

    // Total general
    $stmt = $pdo->query("
        SELECT
            SUM(total_requerimientos) AS total,
            SUM(entregados) AS entregados,
            SUM(pendientes) AS pendientes,
            SUM(vencidos) AS vencidos,
            SUM(cancelados) AS cancelados,
            SUM(monto_total) AS monto
        FROM publico.recaudadora_estadreq('')
    ");
    $global = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   RESUMEN GENERAL:\n";
    echo "   Total de requerimientos: " . number_format($global['total']) . "\n";
    echo "   Entregados: " . number_format($global['entregados']) . " (" . round($global['entregados']/$global['total']*100, 1) . "%)\n";
    echo "   Pendientes: " . number_format($global['pendientes']) . " (" . round($global['pendientes']/$global['total']*100, 1) . "%)\n";
    echo "   Vencidos: " . number_format($global['vencidos']) . " (" . round($global['vencidos']/$global['total']*100, 1) . "%)\n";
    echo "   Cancelados: " . number_format($global['cancelados']) . " (" . round($global['cancelados']/$global['total']*100, 1) . "%)\n";
    echo "   Monto total: $" . number_format($global['monto'], 2) . "\n";

    // 6. Ejecutores más activos
    echo "\n\n6. Top 5 ejecutores más activos...\n";
    $stmt = $pdo->query("
        SELECT
            ejecutor,
            SUM(total_requerimientos) AS total
        FROM publico.recaudadora_estadreq('')
        WHERE ejecutor != 'SIN EJECUTOR'
        GROUP BY ejecutor
        ORDER BY total DESC
        LIMIT 5
    ");
    $top_ejecutores = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($top_ejecutores as $i => $ej) {
        echo "   " . ($i + 1) . ". {$ej['ejecutor']}: " . number_format($ej['total']) . " requerimientos\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
