<?php
// Desplegar y probar SP: recaudadora_relmes
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_relmes ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_relmes.sql');
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // EJEMPLO 1: Mes específico (Agosto 2025)
    echo "=== EJEMPLO 1: Agosto 2025 (Mes específico) ===\n";
    echo "Campos del formulario:\n";
    echo "  Mes: 8\n";
    echo "  Año: 2025\n\n";

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_relmes(?, ?)");
    $stmt1->execute(['8', 2025]);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result1) . " dependencias\n\n";
    foreach ($result1 as $row) {
        echo sprintf(
            "  Dep: %d %-25s | Multas: %4d | Total: $%12.2f\n",
            $row['dependencia'],
            $row['nombre_dependencia'],
            $row['cantidad_multas'],
            $row['total_general']
        );
    }

    // EJEMPLO 2: Julio 2025
    echo "\n\n=== EJEMPLO 2: Julio 2025 ===\n";
    echo "Campos del formulario:\n";
    echo "  Mes: 7\n";
    echo "  Año: 2025\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_relmes(?, ?)");
    $stmt2->execute(['7', 2025]);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result2) . " dependencias\n\n";
    foreach ($result2 as $row) {
        echo sprintf(
            "  Dep: %d %-25s | Multas: %4d | Total: $%12.2f\n",
            $row['dependencia'],
            $row['nombre_dependencia'],
            $row['cantidad_multas'],
            $row['total_general']
        );
    }

    // EJEMPLO 3: Todo el año 2025 (sin especificar mes)
    echo "\n\n=== EJEMPLO 3: Resumen Anual 2025 (Sin mes) ===\n";
    echo "Campos del formulario:\n";
    echo "  Mes: (dejar vacío)\n";
    echo "  Año: 2025\n\n";

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_relmes(?, ?)");
    $stmt3->execute(['', 2025]);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result3) . " dependencias (resumen anual)\n\n";
    foreach ($result3 as $row) {
        echo sprintf(
            "  Dep: %d %-25s | Multas: %4d | Total: $%12.2f\n",
            $row['dependencia'],
            $row['nombre_dependencia'],
            $row['cantidad_multas'],
            $row['total_general']
        );
    }

    echo "\n\n✅ TODAS LAS PRUEBAS EXITOSAS\n";

    echo "\n=== RESUMEN DE EJEMPLOS ===\n\n";
    echo "1. MES ESPECÍFICO - Agosto 2025:\n";
    echo "   Mes: 8 | Año: 2025 | Dependencias: " . count($result1) . "\n\n";

    echo "2. MES ESPECÍFICO - Julio 2025:\n";
    echo "   Mes: 7 | Año: 2025 | Dependencias: " . count($result2) . "\n\n";

    echo "3. RESUMEN ANUAL - Año completo 2025:\n";
    echo "   Mes: (vacío) | Año: 2025 | Dependencias: " . count($result3) . "\n\n";

    // Calcular totales del año
    $total_multas = array_sum(array_column($result3, 'cantidad_multas'));
    $total_importe = array_sum(array_column($result3, 'total_general'));

    echo "\n📊 ESTADÍSTICAS AÑO 2025:\n";
    echo "   Total de multas: " . number_format($total_multas) . "\n";
    echo "   Total recaudado: $" . number_format($total_importe, 2) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
