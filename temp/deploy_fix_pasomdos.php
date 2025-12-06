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

    echo "Desplegando corrección de sp_pasomdos_insert_tianguis...\n";

    $sql = file_get_contents(__DIR__ . '/fix_pasomdos_sp.sql');
    $sql = preg_replace('/\\\\c\s+\w+;?/', '', $sql);

    $pdo->exec($sql);

    echo "✓ SP corregido y desplegado exitosamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
