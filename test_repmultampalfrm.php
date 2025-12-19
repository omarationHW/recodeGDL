<?php
// Script para probar el stored procedure recaudadora_repmultampalfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_repmultampalfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_repmultampalfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar reporte del ejercicio fiscal 2024
    echo "2. Probando reporte mensual del ejercicio fiscal 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repmultampalfrm(2024)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total meses con actividad: " . count($result) . "\n\n";

    if (count($result) > 0) {
        echo "   Reporte Mensual (Ejercicio 2024):\n";
        echo "   Mes | Nombre      | Cant.Multas | Tot.Multas      | Tot.Gastos  | Tot.General     | Promedio\n";
        echo "   --------------------------------------------------------------------------------------------------------\n";

        $total_cantidad = 0;
        $total_multas = 0;
        $total_gastos = 0;
        $total_general = 0;

        foreach ($result as $row) {
            printf("   %3d | %-11s | %11d | $%14.2f | $%10.2f | $%14.2f | $%10.2f\n",
                $row['mes'],
                $row['nombre_mes'],
                $row['cantidad_multas'],
                $row['total_multas'],
                $row['total_gastos'],
                $row['total_general'],
                $row['promedio_multa']
            );

            $total_cantidad += $row['cantidad_multas'];
            $total_multas += $row['total_multas'];
            $total_gastos += $row['total_gastos'];
            $total_general += $row['total_general'];
        }

        echo "   --------------------------------------------------------------------------------------------------------\n";
        $promedio_anual = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;
        printf("   TOTALES:              %11d | $%14.2f | $%10.2f | $%14.2f | $%10.2f\n\n",
            $total_cantidad, $total_multas, $total_gastos, $total_general, $promedio_anual);
    }

    // 3. Probar reporte del ejercicio fiscal 2023
    echo "\n3. Probando reporte mensual del ejercicio fiscal 2023...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repmultampalfrm(2023)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total meses con actividad: " . count($result) . "\n";

    if (count($result) > 0) {
        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;

        printf("   Total multas 2023: %s\n", number_format($total_cantidad));
        printf("   Total general 2023: $%s\n", number_format($total_general, 2));
        printf("   Promedio por multa: $%s\n\n", number_format($promedio, 2));

        echo "   Top 3 meses con mayor recaudación 2023:\n";
        usort($result, function($a, $b) {
            return $b['total_general'] <=> $a['total_general'];
        });

        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   " . ($i + 1) . ". {$row['nombre_mes']}: ";
            echo number_format($row['cantidad_multas']) . " multas, Total: $" . number_format($row['total_general'], 2);
            echo " (Promedio: $" . number_format($row['promedio_multa'], 2) . ")\n";
        }
    }

    // 4. Comparar ejercicios fiscales
    echo "\n\n4. Comparación entre ejercicios fiscales...\n";

    $ejercicios = [2022, 2023, 2024];

    echo "   Ejercicio | Meses Activos | Total Multas  | Total General    | Promedio/Multa\n";
    echo "   --------------------------------------------------------------------------------\n";

    foreach ($ejercicios as $ejercicio) {
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repmultampalfrm(?)");
        $stmt->execute([$ejercicio]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));
        $promedio = $total_cantidad > 0 ? $total_general / $total_cantidad : 0;

        printf("   %4d      | %13d | %13s | $%15.2f | $%12.2f\n",
            $ejercicio,
            count($result),
            number_format($total_cantidad),
            $total_general,
            $promedio
        );
    }

    // 5. Análisis de tendencias
    echo "\n\n5. Análisis de tendencias mensuales 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_repmultampalfrm(2024)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        // Ordenar por cantidad de multas
        usort($result, function($a, $b) {
            return $b['cantidad_multas'] <=> $a['cantidad_multas'];
        });

        echo "   Mes con más multas: {$result[0]['nombre_mes']} (" . number_format($result[0]['cantidad_multas']) . " multas)\n";
        echo "   Mes con menos multas: {$result[count($result)-1]['nombre_mes']} (" . number_format($result[count($result)-1]['cantidad_multas']) . " multas)\n";

        // Ordenar por total general
        usort($result, function($a, $b) {
            return $b['total_general'] <=> $a['total_general'];
        });

        echo "   Mes con mayor recaudación: {$result[0]['nombre_mes']} ($" . number_format($result[0]['total_general'], 2) . ")\n";
        echo "   Mes con menor recaudación: {$result[count($result)-1]['nombre_mes']} ($" . number_format($result[count($result)-1]['total_general'], 2) . ")\n";
    }

    // 6. Información adicional
    echo "\n\n6. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Registros totales: 626,583\n";
    echo "   - Filtro: Por ejercicio fiscal (año)\n";
    echo "   - Agregación: Por mes\n";
    echo "   - Campos agregados:\n";
    echo "     * mes: Número del mes (1-12)\n";
    echo "     * nombre_mes: Nombre del mes en español\n";
    echo "     * cantidad_multas: Número de multas en el mes\n";
    echo "     * total_multas: Suma de montos de multas\n";
    echo "     * total_gastos: Suma de gastos de ejecución\n";
    echo "     * total_general: Suma total (multas + gastos)\n";
    echo "     * promedio_multa: Promedio por multa en el mes\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
