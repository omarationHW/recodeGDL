<?php
// Deploy recaudadora_dderechoslic SP

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DEPLOYING recaudadora_dderechoslic ===\n\n";

    // Drop existing function first
    echo "Dropping existing function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_dderechoslic(integer)");

    // Read the SQL file
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_dderechoslic.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("Could not read SQL file: $sqlFile");
    }

    // Execute the SQL
    $pdo->exec($sql);

    echo "✓ Stored procedure created successfully!\n\n";

    // Test the SP with a known licencia
    echo "=== TESTING SP WITH LICENCIA 14862 ===\n\n";

    $stmt = $pdo->query("
        SELECT * FROM multas_reglamentos.recaudadora_dderechoslic(14862)
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($results) . " records\n\n";

    if (count($results) > 0) {
        $first = $results[0];
        echo "Licencia: {$first['licencia']}\n";
        echo "Propietario: " . trim($first['propietario']) . "\n";
        echo "Actividad: " . trim($first['actividad']) . "\n";
        echo "Total Licencia: $" . number_format($first['total_licencia'], 2) . "\n\n";

        echo "Detalle por año (primeros 3):\n";
        $limit = min(3, count($results));
        for ($i = 0; $i < $limit; $i++) {
            $row = $results[$i];
            echo "  Año {$row['axo']}: Derechos=\$" . number_format($row['derechos'], 2) .
                 ", Recargos=\$" . number_format($row['recargos'], 2) .
                 ", Pagado={$row['pagado']}\n";
        }
    }

    echo "\n✓ Test successful!\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
