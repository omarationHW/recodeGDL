<?php
/**
 * VERIFICAR SPs NECESARIOS PARA RptFacturaEmision
 */

$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

$conn = pg_connect(sprintf(
    "host=%s port=%s dbname=%s user=%s password=%s",
    $config['host'], $config['port'], $config['dbname'], $config['user'], $config['password']
));

if (!$conn) {
    die("ERROR: No se pudo conectar a la BD\n");
}

echo "==============================================\n";
echo "VERIFICACIÓN DE SPs PARA RptFacturaEmision\n";
echo "==============================================\n\n";

$sps = [
    'sp_rpt_factura_emision',
    'sp_get_vencimiento_rec',
    'sp_get_recaudadoras',
    'sp_get_mercados_by_recaudadora'
];

$found = 0;
$missing = [];

foreach ($sps as $sp) {
    $query = "
        SELECT proname, pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public' AND p.proname = '$sp'
    ";

    $result = pg_query($conn, $query);

    if ($result && pg_num_rows($result) > 0) {
        $row = pg_fetch_assoc($result);
        echo "✓ $sp\n";
        echo "  Args: {$row['args']}\n\n";
        $found++;
    } else {
        echo "✗ $sp - NO EXISTE\n\n";
        $missing[] = $sp;
    }
}

pg_close($conn);

echo "==============================================\n";
echo "RESUMEN\n";
echo "==============================================\n";
echo "SPs encontrados: $found/4\n";
echo "SPs faltantes: " . count($missing) . "\n";

if (count($missing) > 0) {
    echo "\nSPs que faltan:\n";
    foreach ($missing as $sp) {
        echo "  - $sp\n";
    }
}

echo "\n==============================================\n";
