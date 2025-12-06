<?php
/**
 * DESPLEGAR 3 SPs FALTANTES
 */

echo "========================================\n";
echo "DESPLIEGUE DE 3 SPs\n";
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
    'CuotasEnergiaMntto_sp_list_cuotas_energia.sql',
    'ModuloBD_sp_get_categorias.sql',
    'CuotasMdoMntto_cuotasmdo_listar.sql'
];

$success = 0;
$errors = 0;

foreach ($files as $i => $file) {
    echo "[" . ($i+1) . "/3] Desplegando: $file\n";

    $sql = file_get_contents($sqlDir . $file);

    if ($sql === false) {
        echo "  ✗ ERROR: No se pudo leer el archivo\n\n";
        $errors++;
        continue;
    }

    // Extraer nombre del SP
    preg_match('/CREATE OR REPLACE FUNCTION\s+(\w+)\s*\(/i', $sql, $m);
    $sp = $m[1] ?? 'desconocido';
    echo "  → SP: $sp\n";

    $result = @pg_query($conn, $sql);

    if ($result) {
        echo "  ✓ Desplegado exitosamente\n\n";
        $success++;
    } else {
        $error = pg_last_error($conn);
        echo "  ✗ ERROR: $error\n\n";
        $errors++;
    }
}

pg_close($conn);

echo "\n========================================\n";
echo "RESUMEN\n";
echo "========================================\n";
echo "Exitosos: $success/3 ✓\n";
echo "Errores:  $errors/3 ✗\n";

if ($success == 3) {
    echo "\n¡TODOS LOS SPs DESPLEGADOS EXITOSAMENTE!\n";
}

echo "========================================\n";

exit($errors > 0 ? 1 : 0);
