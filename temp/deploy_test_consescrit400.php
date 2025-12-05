<?php
// Deploy and test recaudadora_consescrit400 SP

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
    $sqlFile = 'C:/recodeGDL/RefactorX/Base/multas_reglamentos/database/generated/recaudadora_consescrit400.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando SP recaudadora_consescrit400...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Primero obtener cuentas con datos
    echo "=== Buscando cuentas con requerimientos ===\n";
    $stmt = $pdo->query("
        SELECT cvecuenta, COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        GROUP BY cvecuenta
        ORDER BY total DESC
        LIMIT 5
    ");
    $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($accounts)) {
        echo "No se encontraron registros en la tabla reqdiftransmision\n";
        echo "Generando datos de prueba...\n\n";

        // Si no hay datos, intentar insertar algunos de prueba
        $testData = [
            ['cuenta' => 100001, 'folio' => 1, 'axo' => 2024, 'total' => 1400.00],
            ['cuenta' => 100002, 'folio' => 2, 'axo' => 2024, 'total' => 2100.00],
            ['cuenta' => 100003, 'folio' => 3, 'axo' => 2023, 'total' => 1800.00],
        ];

        foreach ($testData as $data) {
            try {
                $pdo->exec("
                    INSERT INTO catastro_gdl.reqdiftransmision
                    (cvereq, axoreq, folioreq, cvecuenta, total, vigencia, fecemi, feccap)
                    VALUES
                    (
                        (SELECT COALESCE(MAX(cvereq), 0) + 1 FROM catastro_gdl.reqdiftransmision),
                        {$data['axo']},
                        {$data['folio']},
                        {$data['cuenta']},
                        {$data['total']},
                        'V',
                        CURRENT_DATE,
                        CURRENT_DATE
                    )
                ");
                echo "  Insertado registro para cuenta {$data['cuenta']}\n";
            } catch (Exception $e) {
                echo "  Error insertando cuenta {$data['cuenta']}: " . $e->getMessage() . "\n";
            }
        }

        // Volver a consultar
        $stmt = $pdo->query("
            SELECT cvecuenta, COUNT(*) as total
            FROM catastro_gdl.reqdiftransmision
            GROUP BY cvecuenta
            ORDER BY total DESC
            LIMIT 5
        ");
        $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo "\nCuentas disponibles para pruebas:\n";
    foreach ($accounts as $account) {
        echo "  Cuenta {$account['cvecuenta']}: {$account['total']} requerimientos\n";
    }

    // Probar con las primeras 3 cuentas
    echo "\n=== EJEMPLOS DE PRUEBA ===\n\n";
    $testAccounts = array_slice($accounts, 0, 3);

    foreach ($testAccounts as $idx => $account) {
        $cuentaNum = $account['cvecuenta'];
        echo "EJEMPLO " . ($idx + 1) . ": Cuenta $cuentaNum\n";

        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_consescrit400(:cuenta)");
        $stmt->execute(['cuenta' => (string)$cuentaNum]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($results)) {
            echo "Sin registros encontrados\n\n";
        } else {
            echo "Registros encontrados: " . count($results) . "\n";
            echo json_encode($results[0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";
        }
    }

    echo "✓ Todas las pruebas completadas\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
