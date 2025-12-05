<?php
// Deploy recaudadora_consultapredial SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_consultapredial ===\n\n";

    // Read the SQL file
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_consultapredial.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("Could not read SQL file: $sqlFile");
    }

    // Execute the SQL
    $pdo->exec($sql);

    echo "✓ Stored procedure created successfully!\n\n";

    // Test the SP with a known cvecat
    echo "=== TESTING SP ===\n\n";

    $stmt = $pdo->query("
        SELECT * FROM multas_reglamentos.recaudadora_consultapredial('D65I3950016')
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "Test successful! Result:\n\n";
        foreach ($result as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
    } else {
        echo "No results returned\n";
    }

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
