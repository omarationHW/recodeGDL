<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== VERIFICANDO SP ===\n\n";

    // Verificar que existe
    $checkQuery = "
        SELECT 
            p.proname,
            pg_get_function_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_cuotas_energia_create'
        AND n.nspname = 'public'
    ";
    
    $stmt = $pdo->query($checkQuery);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($sp) {
        echo "✓ SP encontrado\n";
        echo "Nombre: {$sp['proname']}\n";
        echo "Argumentos: {$sp['args']}\n\n";
    } else {
        echo "✗ SP NO encontrado\n";
        return;
    }

    // Probar con CAST explícito
    echo "=== PROBANDO SP CON CAST ===\n";
    $testQuery = "SELECT * FROM sp_cuotas_energia_create(2025::smallint, 1::smallint, 25.50::numeric(18,6), 1::integer)";
    $stmt = $pdo->query($testQuery);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "✓ Cuota creada con ID: {$result['id_kilowhatts']}\n";

    // Eliminar el registro de prueba
    $deleteQuery = "DELETE FROM public.ta_11_kilowhatts WHERE id_kilowhatts = {$result['id_kilowhatts']}";
    $pdo->exec($deleteQuery);
    echo "✓ Registro de prueba eliminado\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
