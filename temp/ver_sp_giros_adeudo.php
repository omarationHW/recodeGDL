<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "Buscando SP de GirosDconAdeudofrm...\n\n";

    $stmt = $pdo->query("
        SELECT
            p.proname as nombre_sp,
            pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%giros%adeudo%'
        AND n.nspname = 'public'
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "SP: " . $sp['nombre_sp'] . "\n";
            echo str_repeat("=", 80) . "\n";
            echo $sp['definicion'] . "\n\n";
        }
    } else {
        echo "No se encontró el SP\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
