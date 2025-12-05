<?php
// Desplegar y probar SP: recaudadora_rep_oper
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_rep_oper ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_rep_oper.sql');
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // EJEMPLO 1: Primera semana de Agosto 2025
    echo "=== EJEMPLO 1: Primera semana de Agosto 2025 ===\n";
    echo "Campos del formulario:\n";
    echo "  Desde: 2025-08-01\n";
    echo "  Hasta: 2025-08-07\n\n";

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_rep_oper(?, ?)");
    $stmt1->execute(['2025-08-01', '2025-08-07']);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result1) . " dependencias\n\n";
    $total1_oper = 0;
    $total1_monto = 0;
    foreach ($result1 as $row) {
        echo sprintf(
            "  Dep: %2d %-25s | Operaciones: %4d | Total: $%12.2f\n",
            $row['dependencia'],
            $row['nombre_dependencia'],
            $row['cantidad_operaciones'],
            $row['total_general']
        );
        $total1_oper += $row['cantidad_operaciones'];
        $total1_monto += $row['total_general'];
    }
    echo sprintf("\n  TOTALES: %d operaciones | $%.2f\n", $total1_oper, $total1_monto);

    // EJEMPLO 2: Segunda semana de Agosto 2025
    echo "\n\n=== EJEMPLO 2: Segunda semana de Agosto 2025 ===\n";
    echo "Campos del formulario:\n";
    echo "  Desde: 2025-08-08\n";
    echo "  Hasta: 2025-08-14\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_rep_oper(?, ?)");
    $stmt2->execute(['2025-08-08', '2025-08-14']);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result2) . " dependencias\n\n";
    $total2_oper = 0;
    $total2_monto = 0;
    foreach ($result2 as $row) {
        echo sprintf(
            "  Dep: %2d %-25s | Operaciones: %4d | Total: $%12.2f\n",
            $row['dependencia'],
            $row['nombre_dependencia'],
            $row['cantidad_operaciones'],
            $row['total_general']
        );
        $total2_oper += $row['cantidad_operaciones'];
        $total2_monto += $row['total_general'];
    }
    echo sprintf("\n  TOTALES: %d operaciones | $%.2f\n", $total2_oper, $total2_monto);

    // EJEMPLO 3: Tercera semana de Agosto 2025
    echo "\n\n=== EJEMPLO 3: Tercera semana de Agosto 2025 ===\n";
    echo "Campos del formulario:\n";
    echo "  Desde: 2025-08-15\n";
    echo "  Hasta: 2025-08-21\n\n";

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_rep_oper(?, ?)");
    $stmt3->execute(['2025-08-15', '2025-08-21']);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result3) . " dependencias\n\n";
    $total3_oper = 0;
    $total3_monto = 0;
    foreach ($result3 as $row) {
        echo sprintf(
            "  Dep: %2d %-25s | Operaciones: %4d | Total: $%12.2f\n",
            $row['dependencia'],
            $row['nombre_dependencia'],
            $row['cantidad_operaciones'],
            $row['total_general']
        );
        $total3_oper += $row['cantidad_operaciones'];
        $total3_monto += $row['total_general'];
    }
    echo sprintf("\n  TOTALES: %d operaciones | $%.2f\n", $total3_oper, $total3_monto);

    echo "\n\n✅ TODAS LAS PRUEBAS EXITOSAS\n";

    echo "\n=== RESUMEN DE EJEMPLOS ===\n\n";
    echo "1. PRIMERA SEMANA - Agosto 1-7, 2025:\n";
    echo "   Desde: 2025-08-01 | Hasta: 2025-08-07\n";
    echo "   Dependencias: " . count($result1) . " | Operaciones: $total1_oper | Monto: $" . number_format($total1_monto, 2) . "\n\n";

    echo "2. SEGUNDA SEMANA - Agosto 8-14, 2025:\n";
    echo "   Desde: 2025-08-08 | Hasta: 2025-08-14\n";
    echo "   Dependencias: " . count($result2) . " | Operaciones: $total2_oper | Monto: $" . number_format($total2_monto, 2) . "\n\n";

    echo "3. TERCERA SEMANA - Agosto 15-21, 2025:\n";
    echo "   Desde: 2025-08-15 | Hasta: 2025-08-21\n";
    echo "   Dependencias: " . count($result3) . " | Operaciones: $total3_oper | Monto: $" . number_format($total3_monto, 2) . "\n\n";

    $total_general = $total1_oper + $total2_oper + $total3_oper;
    $monto_general = $total1_monto + $total2_monto + $total3_monto;

    echo "📊 ESTADÍSTICAS GENERALES (3 semanas):\n";
    echo "   Total de operaciones: " . number_format($total_general) . "\n";
    echo "   Total recaudado: $" . number_format($monto_general, 2) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
