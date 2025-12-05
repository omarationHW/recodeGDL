<?php
// Deploy and test recaudadora_consdesc SP

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'sistemas';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a PostgreSQL\n\n";

    // Read and deploy SQL file
    $sqlFile = 'C:/recodeGDL/RefactorX/Base/multas_reglamentos/database/generated/recaudadora_consdesc.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando SP recaudadora_consdesc...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Test examples
    $testAccounts = [
        '379388',
        '35321',
        '405651'
    ];

    foreach ($testAccounts as $account) {
        echo "=== EJEMPLO: Cuenta $account ===\n";

        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_consdesc(:cuenta)");
        $stmt->execute(['cuenta' => $account]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($results)) {
            echo "Sin descuentos encontrados\n\n";
        } else {
            echo "Descuentos encontrados: " . count($results) . "\n";
            echo "Primer descuento:\n";
            echo json_encode($results[0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";
        }
    }

    echo "✓ Todas las pruebas completadas\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
