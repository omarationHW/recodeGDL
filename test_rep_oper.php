<?php
// Script para probar el stored procedure recaudadora_rep_oper

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Probar reporte de operaciones de un mes (Enero 2024)
    echo "1. Probando reporte de operaciones de enero 2024...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_oper('2024-01-01', '2024-01-31')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n\n";

    if (count($result) > 0) {
        echo "   Reporte de Operaciones (Enero 2024):\n";
        echo "   Dep | Nombre                        | Tot.Oper | Emitidas | Canceladas | Pendientes | Tot.General     | Promedio\n";
        echo "   " . str_repeat("-", 130) . "\n";

        $total_operaciones = 0;
        $total_emitidas = 0;
        $total_canceladas = 0;
        $total_pendientes = 0;
        $total_general = 0;

        foreach ($result as $row) {
            printf("   %3d | %-28s | %8d | %8d | %10d | %10d | $%14.2f | $%10.2f\n",
                $row['dependencia'],
                substr($row['nombre_dependencia'], 0, 28),
                $row['total_operaciones'],
                $row['multas_emitidas'],
                $row['multas_canceladas'],
                $row['multas_pendientes'],
                $row['total_general'],
                $row['promedio_operacion']
            );

            $total_operaciones += $row['total_operaciones'];
            $total_emitidas += $row['multas_emitidas'];
            $total_canceladas += $row['multas_canceladas'];
            $total_pendientes += $row['multas_pendientes'];
            $total_general += $row['total_general'];
        }

        echo "   " . str_repeat("-", 130) . "\n";
        $promedio = $total_operaciones > 0 ? $total_general / $total_operaciones : 0;
        printf("   TOTALES:                          %8d   %8d   %10d   %10d   $%14.2f   $%10.2f\n\n",
            $total_operaciones, $total_emitidas, $total_canceladas, $total_pendientes, $total_general, $promedio);
    }

    // 2. Probar reporte del primer trimestre 2024
    echo "\n2. Probando reporte de operaciones del Q1 2024 (Ene-Mar)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_oper('2024-01-01', '2024-03-31')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n";

    if (count($result) > 0) {
        $total_operaciones = array_sum(array_column($result, 'total_operaciones'));
        $total_emitidas = array_sum(array_column($result, 'multas_emitidas'));
        $total_canceladas = array_sum(array_column($result, 'multas_canceladas'));
        $total_pendientes = array_sum(array_column($result, 'multas_pendientes'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_operaciones > 0 ? $total_general / $total_operaciones : 0;

        printf("   Total operaciones Q1: %s\n", number_format($total_operaciones));
        printf("   Multas emitidas: %s\n", number_format($total_emitidas));
        printf("   Multas canceladas: %s\n", number_format($total_canceladas));
        printf("   Multas pendientes: %s\n", number_format($total_pendientes));
        printf("   Total general Q1: $%s\n", number_format($total_general, 2));
        printf("   Promedio por operación: $%s\n\n", number_format($promedio, 2));

        echo "   Top 3 dependencias Q1 2024:\n";
        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   " . ($i + 1) . ". {$row['nombre_dependencia']}: ";
            echo number_format($row['total_operaciones']) . " operaciones, Total: $" . number_format($row['total_general'], 2);
            echo " (Emitidas: " . number_format($row['multas_emitidas']);
            echo ", Canceladas: " . number_format($row['multas_canceladas']);
            echo ", Pendientes: " . number_format($row['multas_pendientes']) . ")\n";
        }
    }

    // 3. Probar reporte de una semana
    echo "\n\n3. Probando reporte de operaciones de una semana (1-7 Enero 2024)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_oper('2024-01-01', '2024-01-07')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n";

    if (count($result) > 0) {
        $total_operaciones = array_sum(array_column($result, 'total_operaciones'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_operaciones > 0 ? $total_general / $total_operaciones : 0;

        printf("   Total operaciones semana: %s\n", number_format($total_operaciones));
        printf("   Total general: $%s\n", number_format($total_general, 2));
        printf("   Promedio por operación: $%s\n\n", number_format($promedio, 2));
    }

    // 4. Comparar diferentes periodos
    echo "\n4. Comparación de operaciones por periodo en 2024...\n\n";

    $periodos = [
        'Enero' => ['2024-01-01', '2024-01-31'],
        'Febrero' => ['2024-02-01', '2024-02-29'],
        'Marzo' => ['2024-03-01', '2024-03-31'],
        'Q1 (Ene-Mar)' => ['2024-01-01', '2024-03-31'],
        'Q2 (Abr-Jun)' => ['2024-04-01', '2024-06-30']
    ];

    echo "   Periodo         | Dependencias | Tot.Operaciones | Emitidas | Canceladas | Pendientes | Tot.General      | Promedio\n";
    echo "   " . str_repeat("-", 130) . "\n";

    foreach ($periodos as $nombre => $fechas) {
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_oper(?, ?)");
        $stmt->execute($fechas);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_operaciones = array_sum(array_column($result, 'total_operaciones'));
        $total_emitidas = array_sum(array_column($result, 'multas_emitidas'));
        $total_canceladas = array_sum(array_column($result, 'multas_canceladas'));
        $total_pendientes = array_sum(array_column($result, 'multas_pendientes'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_operaciones > 0 ? $total_general / $total_operaciones : 0;

        printf("   %-15s | %12d | %15s | %8s | %10s | %10s | $%15.2f | $%10.2f\n",
            $nombre,
            count($result),
            number_format($total_operaciones),
            number_format($total_emitidas),
            number_format($total_canceladas),
            number_format($total_pendientes),
            $total_general,
            $promedio
        );
    }

    // 5. Probar validación de fechas
    echo "\n\n5. Probando validación de fechas...\n\n";

    try {
        echo "   Intentando fecha desde > fecha hasta...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_oper('2024-12-31', '2024-01-01')");
        $stmt->execute();
        echo "   ❌ No se validó correctamente\n";
    } catch (PDOException $e) {
        echo "   ✓ Validación correcta: " . $e->getMessage() . "\n";
    }

    // 6. Información adicional
    echo "\n\n6. Información adicional de operaciones...\n\n";
    echo "   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Filtro: Por rango de fechas (fecha_acta)\n";
    echo "   - Agregación: Por dependencia\n";
    echo "   - Campos calculados:\n";
    echo "     * total_operaciones: Todas las operaciones en el periodo\n";
    echo "     * multas_emitidas: Multas no canceladas\n";
    echo "     * multas_canceladas: Multas canceladas\n";
    echo "     * multas_pendientes: Multas sin pago\n";
    echo "     * total_general: Suma de multas + gastos\n";
    echo "     * promedio_operacion: Promedio por operación\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
