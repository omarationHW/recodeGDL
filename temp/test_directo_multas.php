<?php
/**
 * Prueba directa del SP sin API
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Probando SP directamente...\n\n";

    // Probar con año 2024
    echo "Año 2024:\n";
    $stmt = $pdo->prepare("SELECT * FROM recaudadora_bloqueo_multa('', 2024, 0, 5)");
    $stmt->execute();
    $results2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($results2024) . "\n";

    if (count($results2024) > 0) {
        echo "Primera multa:\n";
        print_r($results2024[0]);
    } else {
        // Buscar en otros años
        echo "\nBuscando en otros años...\n";

        $stmt2 = $pdo->query("
            SELECT axoreq, COUNT(*) as count
            FROM catastro_gdl.reqmultas
            WHERE vigencia IN ('V', 'B')
            GROUP BY axoreq
            ORDER BY axoreq DESC
            LIMIT 5
        ");
        $years = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        foreach ($years as $year) {
            echo "Año {$year['axoreq']}: {$year['count']} registros\n";
        }

        if (!empty($years)) {
            $testYear = $years[0]['axoreq'];
            echo "\nProbando con año $testYear:\n";

            $stmt3 = $pdo->prepare("SELECT * FROM recaudadora_bloqueo_multa('', :year, 0, 5)");
            $stmt3->execute(['year' => $testYear]);
            $resultsTest = $stmt3->fetchAll(PDO::FETCH_ASSOC);

            echo "Registros: " . count($resultsTest) . "\n";
            if (!empty($resultsTest)) {
                echo "Primera multa:\n";
                print_r($resultsTest[0]);
            }
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
