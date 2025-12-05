<?php
// Probar SP: recaudadora_reg
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_reg ===\n\n";

    // Leer y ejecutar el SQL
    $sqlFile = __DIR__ . '/recaudadora_reg.sql';
    $sql = file_get_contents($sqlFile);
    $pdo->exec($sql);

    echo "✅ Stored Procedure desplegado exitosamente\n\n";

    // ===== EJEMPLO 1: Buscar multa por ID =====
    echo "=== EJEMPLO 1: Buscar multa por ID específico (415284) ===\n";
    $ejemplo1 = [
        "tipo" => "id",
        "id_multa" => 415284
    ];

    $json1 = json_encode($ejemplo1);
    echo "JSON: $json1\n\n";

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_reg(?)");
    $stmt1->execute([$json1]);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "RESULTADOS:\n";
    if (empty($result1)) {
        echo "  Sin resultados\n";
    } else {
        foreach ($result1 as $row) {
            echo "  ID: {$row['id_multa']}\n";
            echo "  Dependencia: {$row['id_dependencia']}\n";
            echo "  Acta: {$row['axo_acta']}/{$row['num_acta']}\n";
            echo "  Fecha: {$row['fecha_acta']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Calificación: {$row['calificacion']}\n";
        }
    }

    // ===== EJEMPLO 2: Buscar multas por dependencia =====
    echo "\n\n=== EJEMPLO 2: Buscar multas por dependencia 7 (últimos 30 días, límite 5) ===\n";
    $ejemplo2 = [
        "tipo" => "dependencia",
        "id_dependencia" => 7,
        "fecha_inicio" => "2025-07-01",
        "fecha_fin" => "2025-12-31",
        "limite" => 5
    ];

    $json2 = json_encode($ejemplo2);
    echo "JSON: $json2\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_reg(?)");
    $stmt2->execute([$json2]);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "RESULTADOS:\n";
    if (empty($result2)) {
        echo "  Sin resultados\n";
    } else {
        foreach ($result2 as $row) {
            $contrib = substr($row['contribuyente'], 0, 30);
            echo "  ID: {$row['id_multa']} | Dep: {$row['id_dependencia']} | Acta: {$row['axo_acta']}/{$row['num_acta']} | Fecha: {$row['fecha_acta']} | Contrib: $contrib\n";
        }
    }

    // ===== EJEMPLO 3: Buscar multas por rango de fechas =====
    echo "\n\n=== EJEMPLO 3: Buscar multas por rango de fechas (últimas 10) ===\n";
    $ejemplo3 = [
        "tipo" => "rango",
        "fecha_inicio" => "2025-08-01",
        "fecha_fin" => "2025-08-31",
        "limite" => 10
    ];

    $json3 = json_encode($ejemplo3);
    echo "JSON: $json3\n\n";

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_reg(?)");
    $stmt3->execute([$json3]);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "RESULTADOS:\n";
    if (empty($result3)) {
        echo "  Sin resultados\n";
    } else {
        foreach ($result3 as $row) {
            $contrib = substr($row['contribuyente'], 0, 25);
            echo "  ID: {$row['id_multa']} | Fecha: {$row['fecha_acta']} | Acta: {$row['axo_acta']}/{$row['num_acta']} | Contrib: $contrib\n";
        }
    }

    echo "\n\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
    echo "\n=== 3 EJEMPLOS PARA COPIAR EN EL FORMULARIO ===\n\n";

    echo "EJEMPLO 1 - Buscar por ID:\n";
    echo json_encode([
        "tipo" => "id",
        "id_multa" => 415284
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    echo "EJEMPLO 2 - Buscar por dependencia:\n";
    echo json_encode([
        "tipo" => "dependencia",
        "id_dependencia" => 7,
        "fecha_inicio" => "2025-07-01",
        "fecha_fin" => "2025-12-31",
        "limite" => 5
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    echo "EJEMPLO 3 - Buscar por rango de fechas:\n";
    echo json_encode([
        "tipo" => "rango",
        "fecha_inicio" => "2025-08-01",
        "fecha_fin" => "2025-08-31",
        "limite" => 10
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
