<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST: Llamada SP buscagiro_list\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test: Llamada sin filtros (todos los giros vigentes tipo L)
    echo "Test: Buscar todos los giros vigentes\n";
    $start = microtime(true);

    $stmt = $pdo->prepare("
        SELECT * FROM comun.buscagiro_list(NULL, NULL, 'V')
        LIMIT 10
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Resultados: " . count($results) . "\n";
    echo "⏱ Tiempo: {$duration}ms\n\n";

    if (count($results) > 0) {
        echo "Primer registro:\n";
        foreach ($results[0] as $key => $value) {
            echo sprintf("  %-20s: %s\n", $key, $value);
        }
    }

    echo "\n✅ Test completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
