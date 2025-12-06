<?php
// Script para desplegar sp_localesmodif_modificar_local corregido

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO sp_localesmodif_modificar_local ===\n\n";

    // Leer el archivo SQL
    $sql = file_get_contents(__DIR__ . '/fix_sp_localesmodif_modificar_local.sql');

    if (!$sql) {
        die("Error: No se pudo leer el archivo SQL\n");
    }

    echo "Contenido del SP:\n";
    echo str_repeat('-', 80) . "\n";
    echo $sql . "\n";
    echo str_repeat('-', 80) . "\n\n";

    // Ejecutar el SQL
    echo "Desplegando SP...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Verificar que existe
    $checkQuery = "
        SELECT
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as argumentos,
            pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_localesmodif_modificar_local'
        AND n.nspname = 'public'
    ";

    $stmt = $pdo->query($checkQuery);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✓✓✓ VERIFICACIÓN EXITOSA\n";
        echo "Nombre: {$sp['nombre']}\n";
        echo "Argumentos: {$sp['argumentos']}\n\n";
    } else {
        echo "✗ No se pudo verificar el SP\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
