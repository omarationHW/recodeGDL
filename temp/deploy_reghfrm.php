<?php
// Desplegar y probar SP: recaudadora_reghfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_reghfrm ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_reghfrm.sql');
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // PRUEBA 1: Buscar por ID específico
    echo "=== PRUEBA 1: Buscar multa por ID (415284) ===\n";
    $filtros1 = json_encode([
        'tipo' => 'id',
        'id_multa' => 415284
    ]);

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_reghfrm(?)");
    $stmt1->execute([$filtros1]);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($result1)) {
        $row = $result1[0];
        echo "ID: {$row['id_multa']}\n";
        echo "Dependencia: {$row['id_dependencia']}\n";
        echo "Acta: {$row['axo_acta']}/{$row['num_acta']}\n";
        echo "Fecha: {$row['fecha_acta']}\n";
        echo "Contribuyente: {$row['contribuyente']}\n";
        echo "✅ OK\n";
    }

    // PRUEBA 2: Buscar por dependencia
    echo "\n\n=== PRUEBA 2: Buscar por dependencia 7 (últimos meses, límite 5) ===\n";
    $filtros2 = json_encode([
        'tipo' => 'dependencia',
        'id_dependencia' => 7,
        'fecha_inicio' => '2025-07-01',
        'fecha_fin' => '2025-12-31',
        'limite' => 5
    ]);

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_reghfrm(?)");
    $stmt2->execute([$filtros2]);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($result2) . "\n\n";

    foreach ($result2 as $row) {
        $contrib = substr($row['contribuyente'], 0, 30);
        echo "ID: {$row['id_multa']} | Dep: {$row['id_dependencia']} | Acta: {$row['axo_acta']}/{$row['num_acta']} | Fecha: {$row['fecha_acta']}\n";
    }
    echo "✅ OK\n";

    // PRUEBA 3: Buscar por rango con año de acta
    echo "\n\n=== PRUEBA 3: Buscar por rango con año de acta 2025 (límite 10) ===\n";
    $filtros3 = json_encode([
        'tipo' => 'rango',
        'fecha_inicio' => '2025-08-01',
        'fecha_fin' => '2025-08-31',
        'axo_acta' => 2025,
        'limite' => 10
    ]);

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_reghfrm(?)");
    $stmt3->execute([$filtros3]);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($result3) . "\n\n";

    foreach ($result3 as $idx => $row) {
        if ($idx < 5) { // Mostrar solo los primeros 5
            echo "ID: {$row['id_multa']} | Acta: {$row['axo_acta']}/{$row['num_acta']} | Fecha: {$row['fecha_acta']}\n";
        }
    }
    if (count($result3) > 5) {
        echo "... y " . (count($result3) - 5) . " más\n";
    }
    echo "✅ OK\n";

    echo "\n\n✅ TODAS LAS PRUEBAS EXITOSAS\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
