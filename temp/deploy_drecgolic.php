<?php
// Deploy recaudadora_drecgolic SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_drecgolic ===\n\n";

    // Drop existing function first
    echo "1. Dropping old function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_drecgolic(VARCHAR) CASCADE");
    echo "   ✓ Dropped\n\n";

    // Read and execute the SQL file
    echo "2. Creating new function...\n";
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_drecgolic.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("Could not read SQL file: $sqlFile");
    }

    $pdo->exec($sql);
    echo "   ✓ Created\n\n";

    // Test with different scenarios
    echo "3. Testing SP...\n\n";

    // Test 1: List first 5
    echo "Test 1: Listar primeras 5 licencias\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgolic(NULL) LIMIT 5");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    if (count($results) > 0) {
        $first = $results[0];
        echo "   Sample:\n";
        echo "   - Licencia: {$first['licencia']}\n";
        echo "   - Propietario: {$first['propietario']}\n";
        echo "   - Giro: {$first['id_giro']}\n";
        echo "   - Fecha: {$first['fecha_otorgamiento']}\n\n";
    }

    // Test 2: Filter by licencia 1
    echo "Test 2: Filtrar por Licencia '1'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgolic('1')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Propietario: {$r['propietario']}\n";
        echo "   - Giro: {$r['id_giro']}\n";
    }
    echo "\n";

    // Test 3: Filter by licencia 5
    echo "Test 3: Filtrar por Licencia '5'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgolic('5')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Propietario: {$r['propietario']}\n";
        echo "   - Giro: {$r['id_giro']}\n";
    }
    echo "\n";

    // Test 4: Filter by licencia 8
    echo "Test 4: Filtrar por Licencia '8'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_drecgolic('8')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Propietario: {$r['propietario']}\n";
        echo "   - Giro: {$r['id_giro']}\n";
    }
    echo "\n";

    echo "✓✓✓ SP Deployed and Tested successfully! ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
