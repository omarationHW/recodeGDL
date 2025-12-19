<?php
// Script para probar el stored procedure recaudadora_relmes

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_relmes...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_relmes.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar relación anual (todos los meses de 2024)
    echo "2. Probando relación anual 2024 (todos los meses)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes(NULL, 2024)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias: " . count($result) . "\n\n";

    if (count($result) > 0) {
        echo "   Resumen por dependencia:\n";
        echo "   Dep | Nombre                        | Cant.Multas | Tot.Multas    | Tot.Gastos | Tot.General\n";
        echo "   ------------------------------------------------------------------------------------------------\n";

        $total_cantidad = 0;
        $total_multas = 0;
        $total_gastos = 0;
        $total_general = 0;

        foreach ($result as $row) {
            printf("   %3d | %-28s | %11d | $%12.2f | $%9.2f | $%12.2f\n",
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

        echo "   ------------------------------------------------------------------------------------------------\n";
        printf("   TOTALES: %34d | $%12.2f | $%9.2f | $%12.2f\n\n",
            $total_cantidad, $total_multas, $total_gastos, $total_general);
    }

    // 3. Probar relación mensual específica (junio 2024)
    echo "\n3. Probando relación mensual junio 2024...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('6', 2024)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total dependencias con actividad en junio: " . count($result) . "\n\n";

    if (count($result) > 0) {
        echo "   Top 5 dependencias en junio 2024:\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            echo "   " . ($i + 1) . ". {$row['nombre_dependencia']}: ";
            echo "{$row['cantidad_multas']} multas, Total: $" . number_format($row['total_general'], 2) . "\n";
        }
    }

    // 4. Comparar varios meses de 2024
    echo "\n\n4. Comparación por mes en 2024...\n";

    $meses = [
        '1' => 'Enero',
        '3' => 'Marzo',
        '6' => 'Junio',
        '9' => 'Septiembre'
    ];

    echo "   Mes       | Dependencias | Total Multas  | Total General\n";
    echo "   ---------------------------------------------------------\n";

    foreach ($meses as $num_mes => $nombre_mes) {
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes(?, 2024)");
        $stmt->execute([$num_mes]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_cantidad = array_sum(array_column($result, 'cantidad_multas'));
        $total_general = array_sum(array_column($result, 'total_general'));

        printf("   %-9s | %12d | $%12.2f | $%12.2f\n",
            $nombre_mes,
            count($result),
            $total_cantidad,
            $total_general
        );
    }

    // 5. Información adicional
    echo "\n\n5. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Registros totales: 626,583\n";
    echo "   - Campos agregados:\n";
    echo "     * dependencia: ID de la dependencia municipal\n";
    echo "     * nombre_dependencia: Nombre descriptivo\n";
    echo "     * cantidad_multas: Número de multas en el periodo\n";
    echo "     * total_multas: Suma de montos de multas\n";
    echo "     * total_gastos: Suma de gastos de ejecución\n";
    echo "     * total_general: Suma total (multas + gastos)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
