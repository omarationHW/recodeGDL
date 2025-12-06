<?php
/**
 * VERIFICAR SI LOS 3 SPs EXISTEN EN LA BD
 */

echo "========================================\n";
echo "VERIFICACIÓN DE 3 SPs\n";
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

// SPs a verificar
$sps = [
    'sp_list_cuotas_energia',
    'sp_get_categorias',
    'cuotasmdo_listar'
];

echo "Verificando SPs en la base de datos...\n";
echo "========================================\n\n";

foreach ($sps as $sp) {
    echo "Verificando: $sp\n";

    // Buscar en public schema
    $query = "
        SELECT
            p.proname,
            pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = '$sp'
    ";

    $result = pg_query($conn, $query);

    if ($result && pg_num_rows($result) > 0) {
        $row = pg_fetch_assoc($result);
        echo "  ✓ EXISTE en BD\n";
        echo "  → Argumentos: {$row['args']}\n\n";
    } else {
        echo "  ✗ NO EXISTE en BD\n\n";
    }
}

// Verificar tablas que usan los SPs
echo "\nVerificando tablas necesarias...\n";
echo "========================================\n\n";

$tables = [
    ['name' => 'ta_11_kilowhatts', 'schemas' => ['public', 'mercados.public']],
    ['name' => 'ta_11_categoria', 'schemas' => ['public', 'comun', 'padron_licencias.comun']],
    ['name' => 'ta_11_cuo_locales', 'schemas' => ['public', 'mercados.public']]
];

foreach ($tables as $table) {
    echo "Buscando tabla: {$table['name']}\n";
    $found = false;

    foreach ($table['schemas'] as $schema) {
        $parts = explode('.', $schema);
        if (count($parts) == 2) {
            // Cross-database
            $db = $parts[0];
            $sch = $parts[1];
            $query = "SELECT 1 FROM information_schema.tables WHERE table_schema = '$sch' AND table_name = '{$table['name']}' LIMIT 1";
        } else {
            // Same database
            $query = "SELECT 1 FROM information_schema.tables WHERE table_schema = '$schema' AND table_name = '{$table['name']}' LIMIT 1";
        }

        $result = @pg_query($conn, $query);
        if ($result && pg_num_rows($result) > 0) {
            echo "  ✓ ENCONTRADA en schema: $schema\n";
            $found = true;
            break;
        }
    }

    if (!$found) {
        echo "  ✗ NO ENCONTRADA\n";
    }
    echo "\n";
}

pg_close($conn);

echo "========================================\n";
echo "VERIFICACIÓN COMPLETADA\n";
echo "========================================\n";
