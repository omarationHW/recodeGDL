<?php
// Deploy recaudadora_descmultampalfrm SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_descmultampalfrm ===\n\n";

    // Drop existing function first
    echo "1. Dropping old function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_descmultampalfrm(VARCHAR) CASCADE");
    echo "   ✓ Dropped\n\n";

    // Read and execute the SQL file
    echo "2. Creating new function...\n";
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_descmultampalfrm.sql';
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
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm(NULL)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n\n";

    if (count($results) > 0) {
        $first = $results[0];
        echo "   Sample:\n";
        echo "   - ID Multa: {$first['id_multa']}\n";
        echo "   - Acta: {$first['num_acta']}\n";
        echo "   - Contribuyente: {$first['contribuyente']}\n";
        echo "   - Multa: \${$first['multa']}\n";
        echo "   - Tipo: {$first['tipo_descto']}\n";
        echo "   - Valor: {$first['valor_descuento']}\n";
        echo "   - Estado: {$first['estado_desc']}\n\n";
    }

    // Test 2: Filter by cuenta (ID Multa 191)
    echo "Test 2: Filtrar por ID Multa '191'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('191')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Contribuyente: {$r['contribuyente']}\n";
        echo "   - Descuento: {$r['valor_descuento']} ({$r['tipo_descto']})\n";
    }
    echo "\n";

    // Test 3: Filter by cuenta (ID Multa 224)
    echo "Test 3: Filtrar por ID Multa '224'\n";
    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('224')");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Found " . count($results) . " records\n";
    if (count($results) > 0) {
        $r = $results[0];
        echo "   - Contribuyente: {$r['contribuyente']}\n";
        echo "   - Descuento: {$r['valor_descuento']} ({$r['tipo_descto']})\n";
    }
    echo "\n";

    echo "✓✓✓ SP Deployed and Tested successfully! ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
