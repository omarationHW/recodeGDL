<?php
// Simple test to see what's really happening with inserts

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver los últimos 10 registros ANTES de llamar el SP
    echo "Últimos 10 registros ANTES:\n";
    $stmt = $pdo->query("
        SELECT cvereq, folioreq, axoreq, fecemi, obs
        FROM publico.reqmultas
        ORDER BY cvereq DESC
        LIMIT 10
    ");
    $antes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($antes as $a) {
        echo "  cvereq: {$a['cvereq']}, folioreq: {$a['folioreq']}, axoreq: {$a['axoreq']}, obs: " . substr($a['obs'], 0, 40) . "\n";
    }

    // Llamar al SP
    echo "\n\nLlamando al SP...\n";
    $datos = json_encode([
        'clave_cuenta' => '2042/2025',
        'ejercicio' => 2025,
        'id_multa' => 417195,
        'monto' => 5000.00,
        'gastos' => 500.00,
        'observaciones' => '*** TEST ' . time() . ' ***'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
    $stmt->execute([$datos]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "Resultado del SP:\n";
    echo "  success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
    echo "  mensaje: {$result['mensaje']}\n";
    echo "  cvereq: {$result['cvereq']}\n";

    // Ver los últimos 10 registros DESPUÉS
    echo "\n\nÚltimos 10 registros DESPUÉS:\n";
    $stmt = $pdo->query("
        SELECT cvereq, folioreq, axoreq, fecemi, obs
        FROM publico.reqmultas
        ORDER BY cvereq DESC
        LIMIT 10
    ");
    $despues = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($despues as $d) {
        $highlight = (strpos($d['obs'], '***') !== false) ? '  <--- NUEVO' : '';
        echo "  cvereq: {$d['cvereq']}, folioreq: {$d['folioreq']}, axoreq: {$d['axoreq']}, obs: " . substr($d['obs'], 0, 40) . $highlight . "\n";
    }

    echo "\n\n✅ Test completado!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
