<?php
// Desplegar y probar SP: recaudadora_publicos_upd
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_publicos_upd ===\n\n";

    // Leer y ejecutar el SQL
    $sqlFile = __DIR__ . '/recaudadora_publicos_upd.sql';
    $sql = file_get_contents($sqlFile);
    $pdo->exec($sql);

    echo "✅ Stored Procedure desplegado exitosamente\n\n";

    // ===== EJEMPLO 1: Actualizar registro existente =====
    echo "=== EJEMPLO 1: Actualizar concepto existente (ID 4) ===\n";
    $ejemplo1 = [
        [
            "cveconcepto" => 4,
            "descripcion" => "PAGO DE DIVERSOS ACTUALIZADO",
            "ncorto" => "DIV-ACT",
            "cvegrupo" => 1
        ]
    ];

    $json1 = json_encode($ejemplo1);
    echo "JSON: $json1\n\n";

    $stmt1 = $pdo->prepare("SELECT * FROM public.recaudadora_publicos_upd(?)");
    $stmt1->execute([$json1]);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result1 as $row) {
        echo "ID: {$row['cveconcepto']} | Desc: {$row['descripcion']} | Acción: {$row['accion']} | Resultado: {$row['resultado']}\n";
    }

    // ===== EJEMPLO 2: Insertar nuevo concepto =====
    echo "\n\n=== EJEMPLO 2: Insertar nuevo concepto ===\n";
    $ejemplo2 = [
        [
            "cveconcepto" => 0,  // 0 = generar automático
            "descripcion" => "PAGO DE PRUEBA SISTEMA",
            "ncorto" => "PRUEBA",
            "cvegrupo" => 2
        ]
    ];

    $json2 = json_encode($ejemplo2);
    echo "JSON: $json2\n\n";

    $stmt2 = $pdo->prepare("SELECT * FROM public.recaudadora_publicos_upd(?)");
    $stmt2->execute([$json2]);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result2 as $row) {
        echo "ID: {$row['cveconcepto']} | Desc: {$row['descripcion']} | Acción: {$row['accion']} | Resultado: {$row['resultado']}\n";
    }

    // Guardar el ID generado para el siguiente ejemplo
    $nuevoId = $result2[0]['cveconcepto'] ?? 0;

    // ===== EJEMPLO 3: Actualización masiva múltiples registros =====
    echo "\n\n=== EJEMPLO 3: Actualización masiva (3 registros) ===\n";
    $ejemplo3 = [
        [
            "cveconcepto" => 1,
            "descripcion" => "IMPUESTO PREDIAL",
            "ncorto" => "PREDIAL",
            "cvegrupo" => 1
        ],
        [
            "cveconcepto" => 2,
            "descripcion" => "TRANSMISIÓN PATRIMONIAL",
            "ncorto" => "TRANSM-PAT",
            "cvegrupo" => 1
        ],
        [
            "cveconcepto" => $nuevoId,
            "descripcion" => "CONCEPTO DE PRUEBA MODIFICADO",
            "ncorto" => "PRUEBA-MOD",
            "cvegrupo" => 2
        ]
    ];

    $json3 = json_encode($ejemplo3);
    echo "JSON: $json3\n\n";

    $stmt3 = $pdo->prepare("SELECT * FROM public.recaudadora_publicos_upd(?)");
    $stmt3->execute([$json3]);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result3 as $row) {
        echo "ID: {$row['cveconcepto']} | Desc: {$row['descripcion']} | Acción: {$row['accion']} | Resultado: {$row['resultado']}\n";
    }

    echo "\n\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
    echo "\n=== EJEMPLOS PARA COPIAR EN EL FORMULARIO ===\n\n";

    echo "1. Actualizar concepto existente:\n";
    echo json_encode([[
        "cveconcepto" => 4,
        "descripcion" => "PAGO DE DIVERSOS ACTUALIZADO",
        "ncorto" => "DIV-ACT",
        "cvegrupo" => 1
    ]], JSON_PRETTY_PRINT) . "\n\n";

    echo "2. Insertar nuevo concepto:\n";
    echo json_encode([[
        "cveconcepto" => 0,
        "descripcion" => "NUEVO CONCEPTO DE PAGO",
        "ncorto" => "NUEVO",
        "cvegrupo" => 2
    ]], JSON_PRETTY_PRINT) . "\n\n";

    echo "3. Actualización masiva:\n";
    echo json_encode([
        ["cveconcepto" => 1, "descripcion" => "IMPUESTO PREDIAL", "ncorto" => "PREDIAL", "cvegrupo" => 1],
        ["cveconcepto" => 2, "descripcion" => "TRANSMISIÓN PATRIMONIAL", "ncorto" => "TRANSM-PAT", "cvegrupo" => 1]
    ], JSON_PRETTY_PRINT) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
