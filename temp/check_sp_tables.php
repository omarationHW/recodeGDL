<?php
echo "==============================================\n";
echo "VERIFICACIÓN: Tablas usadas por los SPs\n";
echo "==============================================\n\n";

$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
]);

echo "1. SP de BUSCAR: sp_localesmodif_buscar_local\n";
$search = $pdo->query("
    SELECT routine_definition
    FROM information_schema.routines
    WHERE routine_name = 'sp_localesmodif_buscar_local'
")->fetch(PDO::FETCH_ASSOC);

if ($search) {
    preg_match_all('/(FROM|JOIN)\s+([a-zA-Z_\.]+)/i', $search['routine_definition'], $matches);
    $tables = array_unique($matches[2]);
    echo "   Tablas consultadas:\n";
    foreach ($tables as $table) {
        echo "   - $table\n";
    }
}

echo "\n2. SP de MODIFICAR: sp_localesmodif_modificar_local\n";
$update = $pdo->query("
    SELECT routine_definition
    FROM information_schema.routines
    WHERE routine_name = 'sp_localesmodif_modificar_local'
")->fetch(PDO::FETCH_ASSOC);

if ($update) {
    preg_match_all('/UPDATE\s+([a-zA-Z_\.]+)/i', $update['routine_definition'], $matches);
    $tables = array_unique($matches[1]);
    echo "   Tablas actualizadas:\n";
    foreach ($tables as $table) {
        echo "   - $table\n";
    }
}

echo "\n3. Verificando datos en ambas tablas para id_local=11257...\n";

echo "\n   En ta_11_locales (tabla principal):\n";
$main = $pdo->query("
    SELECT id_local, nombre, domicilio, sector, giro
    FROM publico.ta_11_locales
    WHERE id_local = 11257
")->fetch(PDO::FETCH_ASSOC);

if ($main) {
    echo "   - nombre: {$main['nombre']}\n";
    echo "   - domicilio: {$main['domicilio']}\n";
    echo "   - sector: {$main['sector']}\n";
    echo "   - giro: {$main['giro']}\n";
} else {
    echo "   ✗ No encontrado\n";
}

echo "\n   En ta_11_localpaso (tabla temporal):\n";
$temp = $pdo->query("
    SELECT id_local, nombre, domicilio, sector, giro
    FROM public.ta_11_localpaso
    WHERE id_local = 11257
")->fetch(PDO::FETCH_ASSOC);

if ($temp) {
    echo "   - nombre: {$temp['nombre']}\n";
    echo "   - domicilio: {$temp['domicilio']}\n";
    echo "   - sector: {$temp['sector']}\n";
    echo "   - giro: {$temp['giro']}\n";
} else {
    echo "   ✗ No encontrado\n";
}

echo "\n==============================================\n";
echo "CONCLUSIÓN\n";
echo "==============================================\n";
echo "Si los datos son diferentes en ambas tablas,\n";
echo "significa que el SP de modificar está guardando\n";
echo "en la tabla temporal (ta_11_localpaso) en lugar\n";
echo "de la tabla principal (ta_11_locales).\n";
?>
