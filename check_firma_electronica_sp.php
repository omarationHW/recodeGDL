<?php
// Script para revisar el stored procedure de firma electrónica

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el stored procedure actual
    echo "=== STORED PROCEDURE ACTUAL: recaudadora_firma_electronica ===\n\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(oid) as definition
        FROM pg_proc
        WHERE proname = 'recaudadora_firma_electronica'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'publico')
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n\n";
    } else {
        echo "No se encontró el stored procedure.\n\n";
    }

    echo "\n✅ Revisión completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
