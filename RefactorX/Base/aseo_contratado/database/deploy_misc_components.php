<?php
/**
 * Deploy Miscellaneous Components Stored Procedures
 * Aseo Contratado Module
 * RefactorX Project
 */

// Database connection parameters
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

// SQL files to deploy
$sqlFiles = [
    'DescuentosPago_all_procedures.sql',
    'EjerciciosGestion_all_procedures.sql',
    'EstGral2_all_procedures.sql',
    'Ins_b_all_procedures.sql',
    'RelacionContratos_all_procedures.sql'
];

$baseDir = __DIR__ . '/database/';

try {
    // Connect to PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "==============================================\n";
    echo "Deploying Miscellaneous Components SPs\n";
    echo "Database: $dbname @ $host\n";
    echo "==============================================\n\n";

    $totalSuccess = 0;
    $totalErrors = 0;

    foreach ($sqlFiles as $file) {
        $filePath = $baseDir . $file;

        if (!file_exists($filePath)) {
            echo "❌ File not found: $file\n";
            $totalErrors++;
            continue;
        }

        echo "Processing: $file\n";

        try {
            $sql = file_get_contents($filePath);

            if (empty($sql)) {
                echo "  ⚠️  Empty file\n";
                continue;
            }

            // Execute SQL
            $pdo->exec($sql);
            echo "  ✅ Deployed successfully\n";
            $totalSuccess++;

        } catch (PDOException $e) {
            echo "  ❌ Error: " . $e->getMessage() . "\n";
            $totalErrors++;
        }

        echo "\n";
    }

    echo "==============================================\n";
    echo "Deployment Summary\n";
    echo "==============================================\n";
    echo "✅ Successful: $totalSuccess\n";
    echo "❌ Errors: $totalErrors\n";
    echo "📊 Total: " . count($sqlFiles) . "\n";
    echo "==============================================\n";

    // Verify deployment
    echo "\nVerifying deployed functions...\n";
    echo "==============================================\n";

    $verifySQL = "
        SELECT
            p.proname as function_name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments,
            d.description
        FROM pg_proc p
        LEFT JOIN pg_description d ON d.objoid = p.oid
        WHERE p.pronamespace = 'public'::regnamespace
          AND p.proname LIKE '%descuentospago%'
           OR p.proname LIKE '%ejercicios%'
           OR p.proname LIKE '%estgral2%'
           OR p.proname LIKE '%ins_b%'
           OR p.proname LIKE '%relacioncontratos%'
        ORDER BY p.proname;
    ";

    $stmt = $pdo->query($verifySQL);
    $functions = $stmt->fetchAll();

    if (empty($functions)) {
        echo "⚠️  No functions found\n";
    } else {
        foreach ($functions as $func) {
            echo "✅ " . $func['function_name'];
            if (!empty($func['arguments'])) {
                echo "(" . $func['arguments'] . ")";
            }
            echo "\n";
            if (!empty($func['description'])) {
                echo "   " . $func['description'] . "\n";
            }
        }
    }

    echo "\n==============================================\n";
    echo "✅ Deployment completed successfully!\n";
    echo "==============================================\n";

} catch (PDOException $e) {
    echo "\n❌ Database connection error: " . $e->getMessage() . "\n";
    exit(1);
}
