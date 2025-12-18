<?php
// Script para probar el stored procedure recaudadora_gastos_transmision actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_gastos_transmision...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_gastos_transmision.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar cuentas de ejemplo
    echo "2. Buscando cuentas de ejemplo en reqdiftransmision...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta, axoreq, fecemi,
               impuesto, recargos, gastos, multa, total
        FROM public.reqdiftransmision
        WHERE cvecuenta IS NOT NULL
          AND total > 0
        ORDER BY fecemi DESC
        LIMIT 5
    ");
    $cuentas_ejemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas encontradas:\n";
    foreach ($cuentas_ejemplo as $c) {
        echo "     - Cuenta: {$c['cvecuenta']}, Año: {$c['axoreq']}, Fecha: {$c['fecemi']}, Total: $" . number_format($c['total'], 2) . "\n";
    }

    if (count($cuentas_ejemplo) > 0) {
        $cuenta_test = $cuentas_ejemplo[0];

        // 3. Probar consulta con cuenta específica
        echo "\n\n3. Probando consulta para cuenta {$cuenta_test['cvecuenta']}...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_gastos_transmision(?, ?)");
        $stmt->execute([$cuenta_test['cvecuenta'], $cuenta_test['axoreq']]);
        $gastos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($gastos) . " gasto(s) encontrado(s)\n\n";

        if (count($gastos) > 0) {
            echo "   Detalles de los gastos:\n";
            $total_gastos = 0;
            foreach ($gastos as $g) {
                echo "     - Cuenta: {$g['clave_cuenta']}, Concepto: {$g['concepto']}, Importe: $" . number_format($g['importe'], 2) . ", Fecha: {$g['fecha']}\n";
                $total_gastos += $g['importe'];
            }
            echo "     TOTAL: $" . number_format($total_gastos, 2) . "\n";
        }

        // 4. Probar sin filtros (todas las cuentas)
        echo "\n\n4. Probando sin filtros (todos los gastos)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_gastos_transmision('', 0)");
        $stmt->execute();
        $gastos_todos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($gastos_todos) . " gasto(s) en total\n";

        if (count($gastos_todos) > 0) {
            echo "   Primeros 5 registros:\n";
            for ($i = 0; $i < min(5, count($gastos_todos)); $i++) {
                $g = $gastos_todos[$i];
                echo "     - Cuenta: {$g['clave_cuenta']}, Concepto: {$g['concepto']}, Importe: $" . number_format($g['importe'], 2) . ", Fecha: {$g['fecha']}\n";
            }
        }

        // 5. Probar filtro por año
        if (count($cuentas_ejemplo) > 1) {
            echo "\n\n5. Probando filtro por año ({$cuenta_test['axoreq']})...\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_gastos_transmision('', ?)");
            $stmt->execute([$cuenta_test['axoreq']]);
            $gastos_año = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Resultados para año {$cuenta_test['axoreq']}: " . count($gastos_año) . " gasto(s)\n";

            // Agrupar por concepto
            $por_concepto = [];
            foreach ($gastos_año as $g) {
                if (!isset($por_concepto[$g['concepto']])) {
                    $por_concepto[$g['concepto']] = ['count' => 0, 'total' => 0];
                }
                $por_concepto[$g['concepto']]['count']++;
                $por_concepto[$g['concepto']]['total'] += $g['importe'];
            }

            echo "\n   Distribución por concepto:\n";
            foreach ($por_concepto as $concepto => $datos) {
                echo "     - {$concepto}: {$datos['count']} registro(s), Total: $" . number_format($datos['total'], 2) . "\n";
            }
        }

        // 6. Probar búsqueda parcial de cuenta
        echo "\n\n6. Probando búsqueda parcial (primeros 3 dígitos)...\n";
        $cuenta_parcial = substr($cuenta_test['cvecuenta'], 0, 3);
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_gastos_transmision(?, 0)");
        $stmt->execute([$cuenta_parcial]);
        $gastos_parcial = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados para cuentas que contienen '{$cuenta_parcial}': " . count($gastos_parcial) . " gasto(s)\n";

        if (count($gastos_parcial) > 0) {
            $cuentas_unicas = array_unique(array_column($gastos_parcial, 'clave_cuenta'));
            echo "   Cuentas encontradas: " . count($cuentas_unicas) . "\n";
            echo "   Primeras 3 cuentas: " . implode(', ', array_slice($cuentas_unicas, 0, 3)) . "\n";
        }
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas de reqdiftransmision...\n";
    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(DISTINCT cvecuenta) as cuentas_unicas,
            SUM(total) as suma_total,
            AVG(total) as promedio_total,
            MIN(fecemi) as fecha_min,
            MAX(fecemi) as fecha_max
        FROM public.reqdiftransmision
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . number_format($stats['total_registros']) . "\n";
    echo "   Cuentas únicas: " . number_format($stats['cuentas_unicas']) . "\n";
    echo "   Suma total: $" . number_format($stats['suma_total'], 2) . "\n";
    echo "   Promedio por registro: $" . number_format($stats['promedio_total'], 2) . "\n";
    echo "   Rango de fechas: {$stats['fecha_min']} a {$stats['fecha_max']}\n";

    // 8. Tipos de gastos disponibles
    echo "\n\n8. Tipos de gastos disponibles:\n";
    $tipos = [
        'impuesto' => 'Impuesto',
        'recargos' => 'Recargos',
        'multa_imp' => 'Multa por Impuesto',
        'multa_ext' => 'Multa Extemporánea',
        'actualizacion' => 'Actualización',
        'gastos' => 'Gastos',
        'gastos_req' => 'Gastos de Requerimiento',
        'multa' => 'Multa'
    ];

    foreach ($tipos as $campo => $nombre) {
        $stmt = $pdo->query("
            SELECT COUNT(*) as cnt, SUM($campo) as total
            FROM public.reqdiftransmision
            WHERE $campo IS NOT NULL AND $campo > 0
        ");
        $tipo_stats = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   {$nombre}: {$tipo_stats['cnt']} registros con este gasto, Total: $" . number_format($tipo_stats['total'], 2) . "\n";
    }

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
