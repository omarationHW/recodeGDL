<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST COMPLETO: buscagiro_list\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test 1: Simular exactamente lo que envía el frontend con tipo='L'
    echo "Test 1: tipo='L', vigente='V' (valores reales)\n";
    echo "========================================\n";
    $start = microtime(true);

    $stmt = $pdo->prepare("SELECT * FROM comun.buscagiro_list(NULL, 'L', 'V') LIMIT 10");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Resultados: " . count($results) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";

    if (count($results) > 0) {
        echo "\n  Primer registro:\n";
        foreach ($results[0] as $key => $value) {
            echo "    $key: " . (is_null($value) ? 'NULL' : $value) . "\n";
        }
    }
    echo "\n";

    // Test 2: tipo=NULL, vigente='V'
    echo "Test 2: tipo=NULL (Todos), vigente='V'\n";
    echo "========================================\n";
    $start = microtime(true);

    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, NULL, 'V')");
    $stmt->execute();
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Total: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    // Test 3: Ambos NULL
    echo "Test 3: tipo=NULL, vigente=NULL (Todos en ambos)\n";
    echo "========================================\n";
    $start = microtime(true);

    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, NULL, NULL)");
    $stmt->execute();
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Total: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    // Test 4: Con descripción
    echo "Test 4: descripcion='restaurante', tipo=NULL, vigente='V'\n";
    echo "========================================\n";
    $start = microtime(true);

    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list('restaurante', NULL, 'V')");
    $stmt->execute();
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Total: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    // Test 5: Verificar que el SP existe
    echo "Test 5: Verificar existencia del SP\n";
    echo "========================================\n";
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'buscagiro_list'
        AND n.nspname = 'comun'
    ");
    $sp_info = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp_info) {
        echo "  ✅ SP encontrado:\n";
        echo "    Schema: {$sp_info['schema']}\n";
        echo "    Nombre: {$sp_info['name']}\n";
        echo "    Argumentos: {$sp_info['arguments']}\n";
    } else {
        echo "  ❌ SP NO encontrado\n";
    }

    echo "\n✅ Todos los tests completados\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
