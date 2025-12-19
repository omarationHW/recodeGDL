<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PRUEBA FINAL: STORED PROCEDURE CON TABLA DE REGISTROS ===\n\n";

    // Caso 1: Consulta con registros
    echo "CASO 1: Consulta de últimos 30 días\n";
    echo "========================================\n";

    $fecha_hasta = date('Y-m-d');
    $fecha_desde = date('Y-m-d', strtotime('-30 days'));

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => $fecha_desde,
        'fecha_hasta' => $fecha_hasta
    ]);

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        $primer_registro = $results[0];
        echo "Status: " . $primer_registro['status'] . "\n";
        echo "Mensaje: " . $primer_registro['mensaje'] . "\n";
        echo "Total registros: " . $primer_registro['total_registros'] . "\n";
        echo "Periodo: $fecha_desde a $fecha_hasta\n\n";

        echo "Primeros 5 registros:\n";
        echo str_repeat("-", 120) . "\n";
        printf("%-12s %-10s %-8s %-8s %-14s %-12s %-6s %-8s %-12s %-12s\n",
            "Fecha", "Criterio", "Recaud", "Urb/Rus", "Cta Inicio", "Cta Final", "Zona", "Subzona", "Monto Min", "Monto Max"
        );
        echo str_repeat("-", 120) . "\n";

        foreach (array_slice($results, 0, 5) as $row) {
            printf("%-12s %-10s %-8s %-8s %-14s %-12s %-6s %-8s $%-11.2f $%-11.2f\n",
                $row['fecha_emision'],
                $row['criterio'],
                $row['recaud'],
                $row['urbrus'],
                $row['cuenta_inicio'],
                $row['cuenta_final'],
                $row['zona'],
                $row['subzona'],
                $row['monto_min'],
                $row['monto_max']
            );
        }
        echo str_repeat("-", 120) . "\n";
    } else {
        echo "No se encontraron registros\n";
    }

    echo "\n\n";

    // Caso 2: Consulta con rango más amplio
    echo "CASO 2: Consulta de todo el año 2024\n";
    echo "========================================\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2024-01-01',
        'fecha_hasta' => '2024-12-31'
    ]);

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        $primer_registro = $results[0];
        echo "Status: " . $primer_registro['status'] . "\n";
        echo "Mensaje: " . $primer_registro['mensaje'] . "\n";
        echo "Total registros: " . $primer_registro['total_registros'] . "\n\n";

        // Estadísticas
        $total_registros = count($results);
        $por_criterio = [];
        $por_recaud = [];

        foreach ($results as $row) {
            $criterio = $row['criterio'];
            $recaud = $row['recaud'];

            if (!isset($por_criterio[$criterio])) {
                $por_criterio[$criterio] = 0;
            }
            $por_criterio[$criterio]++;

            if (!isset($por_recaud[$recaud])) {
                $por_recaud[$recaud] = 0;
            }
            $por_recaud[$recaud]++;
        }

        echo "Estadísticas:\n";
        echo "-------------\n";
        echo "Registros por Criterio:\n";
        foreach ($por_criterio as $criterio => $count) {
            echo "  Criterio $criterio: $count registros\n";
        }
        echo "\nRegistros por Recaudadora:\n";
        foreach ($por_recaud as $recaud => $count) {
            echo "  Recaudadora $recaud: $count registros\n";
        }
    }

    echo "\n\n";

    // Caso 3: Error - fechas inválidas
    echo "CASO 3: Error - fecha desde mayor que fecha hasta\n";
    echo "========================================\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2024-12-31',
        'fecha_hasta' => '2024-01-01'
    ]);

    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Status: " . $result['status'] . "\n";
    echo "Mensaje: " . $result['mensaje'] . "\n";

    echo "\n=== PRUEBA COMPLETADA ===\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
