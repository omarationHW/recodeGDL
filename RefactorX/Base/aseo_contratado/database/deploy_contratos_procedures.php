<?php
/**
 * Deploy Contratos Components Stored Procedures
 *
 * This script deploys all stored procedures for the Contratos components
 * in the aseo_contratado module.
 *
 * Components processed:
 * 1. Contratos.vue - List contracts with filters
 * 2. Contratos_Adeudos.vue - Contracts with debt details
 * 3. Contratos_Alta.vue - Create new contract
 * 4. Contratos_Baja.vue - Delete contract
 * 5. Contratos_Cons_Dom.vue - Search contracts by address
 * 6. Contratos_EstGral.vue - General statistics
 * 7. Contratos_Mod.vue - Modify contract
 * 8. Contratos_Upd_Periodo.vue - Update contract period
 * 9. Contratos_Upd_Und.vue - Update collection units
 * 10. ContratosEst.vue - Contract statistics
 *
 * Database: padron_licencias @ 192.168.6.146
 * Schema: public
 * User: refact
 * Password: FF)-BQk2
 */

// Database connection parameters
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

// Connection string
$connectionString = "host=$host port=$port dbname=$dbname user=$user password=$password";

// SQL files to deploy (in order)
$sqlFiles = [
    'database/Contratos_all_procedures.sql',
    'database/Contratos_Adeudos_all_procedures.sql',
    'database/Contratos_Alta_all_procedures.sql',
    'database/Contratos_Baja_all_procedures.sql',
    'database/Contratos_Upd_Periodo_all_procedures.sql',
    'database/Contratos_Upd_Und_all_procedures.sql',
    'database/ContratosEst_all_procedures.sql',
    'database/sQRptContratos_EstGral_all_procedures.sql',
];

echo "========================================\n";
echo "Deploying Contratos Components Procedures\n";
echo "========================================\n";
echo "Database: $dbname @ $host\n";
echo "Schema: public\n";
echo "Total files: " . count($sqlFiles) . "\n";
echo "========================================\n\n";

// Connect to database
echo "Connecting to database...\n";
$conn = pg_connect($connectionString);

if (!$conn) {
    die("ERROR: Could not connect to database\n");
}

echo "Connected successfully!\n\n";

$totalSuccess = 0;
$totalErrors = 0;

// Deploy each SQL file
foreach ($sqlFiles as $index => $sqlFile) {
    $fileNum = $index + 1;
    $fileName = basename($sqlFile);

    echo "[$fileNum/" . count($sqlFiles) . "] Processing: $fileName\n";

    $filePath = __DIR__ . '/' . $sqlFile;

    if (!file_exists($filePath)) {
        echo "  ERROR: File not found: $filePath\n\n";
        $totalErrors++;
        continue;
    }

    // Read SQL file
    $sql = file_get_contents($filePath);

    if ($sql === false) {
        echo "  ERROR: Could not read file\n\n";
        $totalErrors++;
        continue;
    }

    // Execute SQL
    $result = pg_query($conn, $sql);

    if ($result) {
        echo "  SUCCESS: Procedures deployed\n";
        $totalSuccess++;

        // Count functions created
        $functionCount = preg_match_all('/CREATE OR REPLACE FUNCTION/i', $sql, $matches);
        if ($functionCount > 0) {
            echo "  Functions created: $functionCount\n";
        }
    } else {
        echo "  ERROR: " . pg_last_error($conn) . "\n";
        $totalErrors++;
    }

    echo "\n";
}

// Close connection
pg_close($conn);

// Summary
echo "========================================\n";
echo "DEPLOYMENT SUMMARY\n";
echo "========================================\n";
echo "Total files processed: " . count($sqlFiles) . "\n";
echo "Successful: $totalSuccess\n";
echo "Errors: $totalErrors\n";
echo "========================================\n";

if ($totalErrors === 0) {
    echo "\nSUCCESS: All procedures deployed successfully!\n";
    exit(0);
} else {
    echo "\nWARNING: Some procedures failed to deploy. Check errors above.\n";
    exit(1);
}
