<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PRUEBAS DEL STORED PROCEDURE recaudadora_hastafrm ===\n\n";

    // Caso 1: Fechas válidas
    echo "CASO 1: Fechas válidas\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2024-01-01',
        'fecha_hasta' => '2024-12-31'
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    // Caso 2: Fecha desde nula
    echo "CASO 2: Fecha desde nula\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => null,
        'fecha_hasta' => '2024-12-31'
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    // Caso 3: Fecha hasta nula
    echo "CASO 3: Fecha hasta nula\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2024-01-01',
        'fecha_hasta' => null
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    // Caso 4: Fecha desde mayor que fecha hasta
    echo "CASO 4: Fecha desde mayor que fecha hasta\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2024-12-31',
        'fecha_hasta' => '2024-01-01'
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    // Caso 5: Fecha futura
    echo "CASO 5: Fecha futura\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2024-01-01',
        'fecha_hasta' => '2026-12-31'
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    // Caso 6: Rango mayor a 1 año
    echo "CASO 6: Rango mayor a 1 año\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2023-01-01',
        'fecha_hasta' => '2024-12-31'
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    // Caso 7: Rango válido reciente
    echo "CASO 7: Rango válido reciente (último mes)\n";
    echo "----------------------------------------\n";
    $fecha_hasta = date('Y-m-d');
    $fecha_desde = date('Y-m-d', strtotime('-30 days'));
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_hastafrm(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => $fecha_desde,
        'fecha_hasta' => $fecha_hasta
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    print_r($result);
    echo "\n\n";

    echo "=== PRUEBAS COMPLETADAS ===\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
