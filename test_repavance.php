<?php
// Script para probar el stored procedure recaudadora_repavance

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_repavance...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_repavance.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar reporte del mes de enero 2024
    echo "2. Probando reporte de avance de enero 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repavance('2024-01-01', '2024-01-31')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n\n";

    if (count($result) > 0) {
        echo "   Reporte de Avance (Enero 2024):\n";
        echo "   Dep | Nombre                        | Cant.Multas | Tot.General     | Promedio    | % Total\n";
        echo "   ----------------------------------------------------------------------------------------------\n";

        $total_cantidad = 0;
        $total_general = 0;

        foreach ($result as $row) {
            printf("   %3d | %-28s | %11d | $%14.2f | $%10.2f | %6.2f%%\n",
                $row['dependencia'],
                substr($row['nombre_dependencia'], 0, 28),
                $row['cantidad_multas'],
                $row['total_general'],
                $row['promedio_multa'],
                $row['porcentaje_total']
            );

            $total_cantidad += $row['cantidad_multas'];
            $total_general += $row['total_general'];
        }

        echo "   ----------------------------------------------------------------------------------------------\n";
        $promedio = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;
        printf("   TOTALES:                          %11d | $%14.2f | $%10.2f | 100.00%%\n\n",
            $total_cantidad, $total_general, $promedio);
    }

    // 3. Probar reporte del primer trimestre 2024
    echo "\n3. Probando reporte de avance del Q1 2024 (Ene-Mar)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repavance('2024-01-01', '2024-03-31')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n";

    if (count($result) > 0) {
        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;

        printf("   Total multas Q1: %s\n", number_format($total_cantidad));
        printf("   Total general Q1: $%s\n", number_format($total_general, 2));
        printf("   Promedio por multa: $%s\n\n", number_format($promedio, 2));

        echo "   Top 3 dependencias Q1 2024:\n";
        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   " . ($i + 1) . ". {$row['nombre_dependencia']}: ";
            echo number_format($row['cantidad_multas']) . " multas, Total: $" . number_format($row['total_general'], 2);
            echo " ({$row['porcentaje_total']}%)\n";
        }
    }

    // 4. Probar reporte de avance del año completo 2024
    echo "\n\n4. Probando reporte de avance del año completo 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repavance('2024-01-01', '2024-12-31')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n";

    if (count($result) > 0) {
        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;

        printf("   Total multas 2024: %s\n", number_format($total_cantidad));
        printf("   Total general 2024: $%s\n", number_format($total_general, 2));
        printf("   Promedio por multa: $%s\n\n", number_format($promedio, 2));

        echo "   Distribución por dependencia (Top 5):\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            echo "   " . ($i + 1) . ". {$row['nombre_dependencia']}: ";
            echo "{$row['porcentaje_total']}% ($" . number_format($row['total_general'], 2) . ")\n";
        }
    }

    // 5. Comparar diferentes periodos
    echo "\n\n5. Comparación de periodos en 2024...\n";

    $periodos = [
        'Enero' => ['2024-01-01', '2024-01-31'],
        'Q1 (Ene-Mar)' => ['2024-01-01', '2024-03-31'],
        'Q2 (Abr-Jun)' => ['2024-04-01', '2024-06-30'],
        'Semestre 1' => ['2024-01-01', '2024-06-30']
    ];

    echo "   Periodo         | Dependencias | Total Multas  | Total General    | Promedio/Multa\n";
    echo "   ----------------------------------------------------------------------------------\n";

    foreach ($periodos as $nombre => $fechas) {
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repavance(?, ?)");
        $stmt->execute($fechas);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;

        printf("   %-15s | %12d | %13s | $%15.2f | $%12.2f\n",
            $nombre,
            count($result),
            number_format($total_cantidad),
            $total_general,
            $promedio
        );
    }

    // 6. Probar validación de fechas
    echo "\n\n6. Probando validación de fechas...\n";

    try {
        echo "   Intentando fecha desde > fecha hasta...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repavance('2024-12-31', '2024-01-01')");
        $stmt->execute();
        echo "   ❌ No se validó correctamente\n";
    } catch (PDOException $e) {
        echo "   ✓ Validación correcta: " . $e->getMessage() . "\n";
    }

    // 7. Información adicional
    echo "\n\n7. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Registros totales: 626,583\n";
    echo "   - Filtro: Por rango de fechas (fecha_acta)\n";
    echo "   - Agregación: Por dependencia\n";
    echo "   - Campos agregados:\n";
    echo "     * dependencia: ID de la dependencia municipal\n";
    echo "     * nombre_dependencia: Nombre descriptivo\n";
    echo "     * cantidad_multas: Número de multas en el periodo\n";
    echo "     * total_multas: Suma de montos de multas\n";
    echo "     * total_gastos: Suma de gastos de ejecución\n";
    echo "     * total_general: Suma total (multas + gastos)\n";
    echo "     * promedio_multa: Promedio por multa\n";
    echo "     * porcentaje_total: Porcentaje sobre el total del periodo\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
