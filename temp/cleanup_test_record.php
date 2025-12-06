<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "Eliminando registros de prueba...\n";

    $stmt = $pdo->prepare("
        DELETE FROM comun.ta_11_locales
        WHERE oficina = 1
        AND num_mercado = 214
        AND local = 9000
        AND nombre = 'PRUEBA TEST AUTOMATICO'
    ");
    
    $stmt->execute();
    $deleted = $stmt->rowCount();

    echo "✓ $deleted registro(s) eliminado(s)\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
