<?php
// Deploy recaudadora_drecgo_fosa SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_drecgo_fosa ===\n\n";

    // Drop existing function first
    echo "1. Dropping old function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_drecgo_fosa(INTEGER) CASCADE");
    echo "   ✓ Dropped\n\n";

    // Read and execute the SQL file
    echo "2. Creating new function...\n";
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_drecgo_fosa.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("Could not read SQL file: $sqlFile");
    }

    $pdo->exec($sql);
    echo "   ✓ Created\n\n";

    // Test with different scenarios
    echo "3. Testing SP...\n\n";

    // Test 1: List first 10
    echo "Test 1: Listar primeros 10 fosas\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgo_fosa(NULL) LIMIT 10");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    if (count($results) > 0) {
        $first = $results[0];
        echo "   Sample:\n";
        echo "   - ID: {$first['id_control']}\n";
        echo "   - Nombre: {$first['nombre_titular']}\n";
        echo "   - Cementerio: {$first['cementerio']}\n";
        echo "   - Fosa: {$first['fosa']}\n\n";
    }

    // Test 2: Filter by ID 2
    echo "Test 2: Filtrar por ID '2'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgo_fosa(2)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Nombre: {$r['nombre_titular']}\n";
        echo "   - Cementerio: {$r['cementerio']}\n";
    }
    echo "\n";

    // Test 3: Filter by ID 7
    echo "Test 3: Filtrar por ID '7'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgo_fosa(7)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Nombre: {$r['nombre_titular']}\n";
        echo "   - Cementerio: {$r['cementerio']}\n";
    }
    echo "\n";

    echo "✓✓✓ SP Deployed and Tested successfully! ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
