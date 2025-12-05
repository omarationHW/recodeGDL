<?php
// Deploy recaudadora_descderechos_merc SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_descderechos_merc ===\n\n";

    // Drop existing function first
    echo "1. Dropping old function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_descderechos_merc(VARCHAR, INTEGER) CASCADE");
    echo "   ✓ Dropped\n\n";

    // Read and execute the SQL file
    echo "2. Creating new function...\n";
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_descderechos_merc.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("Could not read SQL file: $sqlFile");
    }

    $pdo->exec($sql);
    echo "   ✓ Created\n\n";

    // Test with different scenarios
    echo "3. Testing SP...\n\n";

    // Test 1: List all
    echo "Test 1: Listar todos los descuentos\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descderechos_merc(NULL, NULL)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    if (count($results) > 0) {
        $first = $results[0];
        echo "   Sample:\n";
        echo "   - Cuenta: {$first['clave_cuenta']}\n";
        echo "   - Local: {$first['nombre']}\n";
        echo "   - Descuento: {$first['descuento']}%\n";
        echo "   - Periodo: {$first['desde']} - {$first['hasta']}\n";
        echo "   - Estatus: {$first['estatus']}\n\n";
    }

    // Test 2: Filter by cuenta
    echo "Test 2: Filtrar por cuenta '1'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descderechos_merc('1', NULL)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    // Test 3: Filter by ejercicio
    echo "Test 3: Filtrar por ejercicio 2024\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descderechos_merc(NULL, 2024)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    echo "✓✓✓ SP Deployed and Tested successfully! ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
