<?php
echo "========================================\n";
echo "RE-DESPLIEGUE FINAL DE 4 SPs\n";
echo "========================================\n\n";

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

if (!$conn) die("ERROR: Conexión fallida\n");

echo "✓ Conexión exitosa\n\n";

$sqlDir = __DIR__ . '/../RefactorX/Base/mercados/database/database/';
$files = [
    'RptAdeudosEnergia_CORREGIDO.sql',
    'RptAdeudosLocales_CORREGIDO.sql',
    'RptCuentaPublica_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos_CORREGIDO.sql'
];

$success = 0;
$errors = 0;

foreach ($files as $i => $file) {
    echo "[" . ($i+1) . "/4] $file\n";
    $sql = file_get_contents($sqlDir . $file);
    preg_match('/CREATE OR REPLACE FUNCTION\s+(?:public\.)?(\w+)\s*\(/i', $sql, $m);
    $sp = $m[1] ?? 'desconocido';
    echo "  → SP: $sp\n";
    $result = @pg_query($conn, $sql);
    if ($result) {
        echo "  ✓ Desplegado exitosamente\n\n";
        $success++;
    } else {
        echo "  ✗ ERROR: " . pg_last_error($conn) . "\n\n";
        $errors++;
    }
}

pg_close($conn);

echo "\n========================================\n";
echo "RESUMEN FINAL\n";
echo "========================================\n";
echo "Exitosos: $success/4 ✓\n";
echo "Errores:  $errors/4 ✗\n";
echo "========================================\n";

exit($errors > 0 ? 1 : 0);
