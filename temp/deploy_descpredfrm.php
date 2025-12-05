<?php
// Deploy recaudadora_descpredfrm SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_descpredfrm ===\n\n";

    // Drop existing function first
    echo "1. Dropping old function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_descpredfrm(VARCHAR) CASCADE");
    echo "   ✓ Dropped\n\n";

    // Read and execute the SQL file
    echo "2. Creating new function...\n";
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_descpredfrm.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("Could not read SQL file: $sqlFile");
    }

    $pdo->exec($sql);
    echo "   ✓ Created\n\n";

    // Test with different scenarios
    echo "3. Testing SP...\n\n";

    // Test 1: List all (limited to first 10)
    echo "Test 1: Listar primeros 10 descuentos\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descpredfrm(NULL) LIMIT 10");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    if (count($results) > 0) {
        $first = $results[0];
        echo "   Sample:\n";
        echo "   - CVE Cuenta: {$first['cvecuenta']}\n";
        echo "   - Descripción: {$first['descripcion']}\n";
        echo "   - Porcentaje: {$first['porcentaje']}%\n";
        echo "   - Ejercicio: {$first['ejercicio']}\n";
        echo "   - Status: {$first['status_desc']}\n\n";
    }

    // Test 2: Filter by cuenta 58
    echo "Test 2: Filtrar por CVE Cuenta '58'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descpredfrm('58')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Solicitante: {$r['solicitante']}\n";
        echo "   - Descuento: {$r['porcentaje']}% ({$r['descripcion']})\n";
    }
    echo "\n";

    // Test 3: Filter by cuenta 60
    echo "Test 3: Filtrar por CVE Cuenta '60'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descpredfrm('60')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Solicitante: {$r['solicitante']}\n";
        echo "   - Descuento: {$r['porcentaje']}% ({$r['descripcion']})\n";
    }
    echo "\n";

    echo "✓✓✓ SP Deployed and Tested successfully! ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
