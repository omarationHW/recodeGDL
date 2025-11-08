<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST SP: consulta_giros_estadisticas\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test 1: Llamada directa al SP
    echo "Test 1: Llamada directa al SP\n";
    echo "========================================\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT * FROM comun.consulta_giros_estadisticas()");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Resultado:\n";
    foreach ($result as $key => $value) {
        echo sprintf("  %-15s: %s\n", $key, number_format($value));
    }
    echo "\n⏱ Tiempo: {$duration}ms\n\n";

    // Test 2: Verificar que el SP existe
    echo "Test 2: Verificar SP en pg_proc\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_result(p.oid) as return_type
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'consulta_giros_estadisticas'
        AND n.nspname = 'comun'
    ");

    $sp_info = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp_info) {
        echo "✅ SP encontrado:\n";
        echo "  Schema: {$sp_info['schema']}\n";
        echo "  Nombre: {$sp_info['name']}\n";
        echo "  Retorna: {$sp_info['return_type']}\n\n";
    } else {
        echo "❌ SP NO encontrado en schema 'comun'\n\n";
    }

    echo "✅ Test completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
