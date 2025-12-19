<?php
// Script para probar el stored procedure recaudadora_rep_desc_impto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_rep_desc_impto...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_repdescimpto.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar reporte del ejercicio fiscal 2024
    echo "2. Probando reporte del ejercicio fiscal 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2024)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n\n";

    if (count($result) > 0) {
        echo "   Reporte por dependencia (Ejercicio 2024):\n";
        echo "   Dep | Nombre                        | Cant.Multas | Tot.Multas      | Tot.Gastos  | Tot.General\n";
        echo "   -----------------------------------------------------------------------------------------------------\n";

        $total_cantidad = 0;
        $total_multas = 0;
        $total_gastos = 0;
        $total_general = 0;

        foreach ($result as $row) {
            printf("   %3d | %-28s | %11d | $%14.2f | $%10.2f | $%14.2f\n",
                $row['dependencia'],
                substr($row['nombre_dependencia'], 0, 28),
                $row['cantidad_multas'],
                $row['total_multas'],
                $row['total_gastos'],
                $row['total_general']
            );

            $total_cantidad += $row['cantidad_multas'];
            $total_multas += $row['total_multas'];
            $total_gastos += $row['total_gastos'];
            $total_general += $row['total_general'];
        }

        echo "   -----------------------------------------------------------------------------------------------------\n";
        printf("   TOTALES: %34d | $%14.2f | $%10.2f | $%14.2f\n\n",
            $total_cantidad, $total_multas, $total_gastos, $total_general);
    }

    // 3. Probar reporte del ejercicio fiscal 2023
    echo "\n3. Probando reporte del ejercicio fiscal 2023...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2023)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n";

    if (count($result) > 0) {
        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));

        printf("   Total multas 2023: %d\n", $total_cantidad);
        printf("   Total general 2023: $%s\n\n", number_format($total_general, 2));

        echo "   Top 3 dependencias 2023:\n";
        usort($result, function($a, $b) {
            return $b['total_general'] <=> $a['total_general'];
        });

        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   " . ($i + 1) . ". {$row['nombre_dependencia']}: ";
            echo "{$row['cantidad_multas']} multas, Total: $" . number_format($row['total_general'], 2) . "\n";
        }
    }

    // 4. Comparar ejercicios fiscales
    echo "\n\n4. Comparación entre ejercicios fiscales...\n";

    $ejercicios = [2022, 2023, 2024];

    echo "   Ejercicio | Dependencias | Total Multas  | Total General\n";
    echo "   ----------------------------------------------------------\n";

    foreach ($ejercicios as $ejercicio) {
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(?)");
        $stmt->execute([$ejercicio]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));

        printf("   %4d      | %12d | %13s | $%14.2f\n",
            $ejercicio,
            count($result),
            number_format($total_cantidad),
            $total_general
        );
    }

    // 5. Información adicional
    echo "\n\n5. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Registros totales: 626,583\n";
    echo "   - Filtro: Por ejercicio fiscal (año)\n";
    echo "   - Agregación: Por dependencia\n";
    echo "   - Campos agregados:\n";
    echo "     * dependencia: ID de la dependencia municipal\n";
    echo "     * nombre_dependencia: Nombre descriptivo\n";
    echo "     * cantidad_multas: Número de multas en el ejercicio\n";
    echo "     * total_multas: Suma de montos de multas\n";
    echo "     * total_gastos: Suma de gastos de ejecución\n";
    echo "     * total_general: Suma total (multas + gastos)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
