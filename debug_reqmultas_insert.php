<?php
// Script para debuggear el INSERT en reqmultas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Ver el último cvereq
    echo "1. Último cvereq antes del test...\n";
    $stmt = $pdo->query("SELECT MAX(cvereq) as max_cvereq FROM publico.reqmultas");
    $max_before = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   MAX cvereq: {$max_before['max_cvereq']}\n\n";

    // 2. Ver los últimos 5 registros
    echo "2. Últimos 5 registros...\n";
    $stmt = $pdo->query("
        SELECT cvereq, folioreq, axoreq, fecemi, id_multa
        FROM publico.reqmultas
        ORDER BY cvereq DESC
        LIMIT 5
    ");
    $ultimos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ultimos as $u) {
        echo "   cvereq: {$u['cvereq']}, folioreq: {$u['folioreq']}, axoreq: {$u['axoreq']}, fecemi: {$u['fecemi']}, id_multa: {$u['id_multa']}\n";
    }

    // 3. Ver qué pasa con currval
    echo "\n\n3. Probando currval...\n";
    try {
        $stmt = $pdo->query("SELECT currval('publico.reqmultas_cvereq_seq') as curr");
        $curr = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   currval actual: {$curr['curr']}\n";
    } catch (Exception $e) {
        echo "   Error: " . $e->getMessage() . "\n";
    }

    echo "\n✅ Debug completado!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
