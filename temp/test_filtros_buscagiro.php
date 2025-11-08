<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST: Filtros buscagiro_list\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test 1: Tipo '' (Todos) - debe mostrar L y A
    echo "Test 1: tipo='' (Todos los tipos)\n";
    echo "========================================\n";
    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM comun.buscagiro_list(NULL, NULL, 'V') LIMIT 10");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Resultados: " . count($results) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    if (count($results) > 0) {
        echo "  Tipos encontrados:\n";
        $tipos = array_unique(array_column($results, 'tipo'));
        foreach ($tipos as $tipo) {
            echo "    - $tipo\n";
        }
    }
    echo "\n";

    // Test 2: Vigencia '' (Todos) - debe mostrar V y C
    echo "Test 2: vigente='' (Todas las vigencias)\n";
    echo "========================================\n";
    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM comun.buscagiro_list(NULL, 'L', NULL) LIMIT 10");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Resultados: " . count($results) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    if (count($results) > 0) {
        echo "  Vigencias encontradas:\n";
        $vigentes = array_unique(array_column($results, 'vigente'));
        foreach ($vigentes as $vigente) {
            echo "    - $vigente\n";
        }
    }
    echo "\n";

    // Test 3: Ambos '' (Todos)
    echo "Test 3: tipo='' y vigente='' (Todos)\n";
    echo "========================================\n";
    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, NULL, NULL)");
    $stmt->execute();
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Total registros: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    // Test 4: Con descripción
    echo "Test 4: descripcion='comercio', tipo='', vigente=''\n";
    echo "========================================\n";
    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list('comercio', NULL, NULL)");
    $stmt->execute();
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Total registros: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    echo "✅ Todos los tests completados\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
