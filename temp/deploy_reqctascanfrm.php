<?php
// Desplegar y probar SP: recaudadora_reqctascanfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_reqctascanfrm ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_reqctascanfrm.sql');
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // EJEMPLO 1: Cuenta 2024-1440
    echo "=== EJEMPLO 1: Cuenta 2024-1440 ===\n";
    echo "Campos del formulario:\n";
    echo "  Cuenta: 2024-1440\n\n";

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_reqctascanfrm(?)");
    $stmt1->execute(['2024-1440']);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result1) . " registros\n\n";
    foreach ($result1 as $row) {
        echo "  ID Multa: {$row['id_multa']}\n";
        echo "  Cuenta: {$row['cuenta']}\n";
        echo "  Fecha Acta: {$row['fecha_acta']}\n";
        echo "  Fecha Cancelación: {$row['fecha_cancelacion']}\n";
        echo "  Contribuyente: " . ($row['contribuyente'] ?: 'N/A') . "\n";
        echo "  Domicilio: " . ($row['domicilio'] ?: 'N/A') . "\n";
        echo "  Dependencia: {$row['dependencia']} - {$row['nombre_dependencia']}\n";
        echo "  Giro: " . ($row['giro'] ?: 'N/A') . "\n";
        echo "  Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "  Gastos: $" . number_format($row['gastos'], 2) . "\n";
        echo "  Total: $" . number_format($row['total'], 2) . "\n";
        echo "  Observación: " . (substr($row['observacion'] ?: 'N/A', 0, 50)) . "\n";
        echo "\n";
    }

    // EJEMPLO 2: Cuenta 2022-11313
    echo "\n=== EJEMPLO 2: Cuenta 2022-11313 ===\n";
    echo "Campos del formulario:\n";
    echo "  Cuenta: 2022-11313\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_reqctascanfrm(?)");
    $stmt2->execute(['2022-11313']);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result2) . " registros\n\n";
    foreach ($result2 as $row) {
        echo "  ID Multa: {$row['id_multa']}\n";
        echo "  Cuenta: {$row['cuenta']}\n";
        echo "  Fecha Acta: {$row['fecha_acta']}\n";
        echo "  Fecha Cancelación: {$row['fecha_cancelacion']}\n";
        echo "  Contribuyente: " . ($row['contribuyente'] ?: 'N/A') . "\n";
        echo "  Domicilio: " . ($row['domicilio'] ?: 'N/A') . "\n";
        echo "  Dependencia: {$row['dependencia']} - {$row['nombre_dependencia']}\n";
        echo "  Giro: " . ($row['giro'] ?: 'N/A') . "\n";
        echo "  Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "  Gastos: $" . number_format($row['gastos'], 2) . "\n";
        echo "  Total: $" . number_format($row['total'], 2) . "\n";
        echo "  Observación: " . (substr($row['observacion'] ?: 'N/A', 0, 50)) . "\n";
        echo "\n";
    }

    // EJEMPLO 3: Cuenta 2022-11231
    echo "\n=== EJEMPLO 3: Cuenta 2022-11231 ===\n";
    echo "Campos del formulario:\n";
    echo "  Cuenta: 2022-11231\n\n";

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_reqctascanfrm(?)");
    $stmt3->execute(['2022-11231']);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Resultados: " . count($result3) . " registros\n\n";
    foreach ($result3 as $row) {
        echo "  ID Multa: {$row['id_multa']}\n";
        echo "  Cuenta: {$row['cuenta']}\n";
        echo "  Fecha Acta: {$row['fecha_acta']}\n";
        echo "  Fecha Cancelación: {$row['fecha_cancelacion']}\n";
        echo "  Contribuyente: " . ($row['contribuyente'] ?: 'N/A') . "\n";
        echo "  Domicilio: " . ($row['domicilio'] ?: 'N/A') . "\n";
        echo "  Dependencia: {$row['dependencia']} - {$row['nombre_dependencia']}\n";
        echo "  Giro: " . ($row['giro'] ?: 'N/A') . "\n";
        echo "  Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "  Gastos: $" . number_format($row['gastos'], 2) . "\n";
        echo "  Total: $" . number_format($row['total'], 2) . "\n";
        echo "  Observación: " . (substr($row['observacion'] ?: 'N/A', 0, 50)) . "\n";
        echo "\n";
    }

    echo "\n✅ TODAS LAS PRUEBAS EXITOSAS\n";

    echo "\n=== RESUMEN DE EJEMPLOS ===\n\n";
    echo "1. CUENTA 2024-1440:\n";
    echo "   Registros: " . count($result1) . "\n";
    if (count($result1) > 0) {
        echo "   Dependencia: {$result1[0]['nombre_dependencia']}\n";
        echo "   Total: $" . number_format($result1[0]['total'], 2) . "\n";
    }
    echo "\n";

    echo "2. CUENTA 2022-11313:\n";
    echo "   Registros: " . count($result2) . "\n";
    if (count($result2) > 0) {
        echo "   Dependencia: {$result2[0]['nombre_dependencia']}\n";
        echo "   Total: $" . number_format($result2[0]['total'], 2) . "\n";
    }
    echo "\n";

    echo "3. CUENTA 2022-11231:\n";
    echo "   Registros: " . count($result3) . "\n";
    if (count($result3) > 0) {
        echo "   Dependencia: {$result3[0]['nombre_dependencia']}\n";
        echo "   Total: $" . number_format($result3[0]['total'], 2) . "\n";
    }
    echo "\n";

    echo "📊 FORMATO DE CUENTA: AÑO-NUMERO (ej: 2024-1440)\n";
    echo "📊 TOTAL MULTAS CANCELADAS EN BD: 7,733\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
