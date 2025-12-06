<?php
$pdo_padron = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo_mercados = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "VERIFICANDO TABLAS PARA sp_reporte_general_mercados\n";
echo "====================================================\n\n";

$tables_to_check = [
    'ta_11_locales' => ['comun', 'publico'],
    'ta_11_mercados' => ['comun', 'publico'],
    'ta_11_pagos_local' => ['public', 'publico'],
    'ta_11_adeudo_local' => ['public', 'publico']
];

foreach ($tables_to_check as $table => $schemas) {
    echo "Tabla: $table\n";
    echo str_repeat("-", 60) . "\n";

    foreach ($schemas as $schema) {
        // Check in padron_licencias
        try {
            $count_padron = $pdo_padron->query("SELECT COUNT(*) FROM $schema.$table")->fetchColumn();
            echo "  ✅ padron_licencias.$schema.$table: " . number_format($count_padron) . " registros\n";
        } catch (PDOException $e) {
            echo "  ❌ padron_licencias.$schema.$table: NO EXISTE\n";
        }

        // Check in mercados
        try {
            $count_mercados = $pdo_mercados->query("SELECT COUNT(*) FROM $schema.$table")->fetchColumn();
            echo "  ✅ mercados.$schema.$table: " . number_format($count_mercados) . " registros\n";
        } catch (PDOException $e) {
            echo "  ❌ mercados.$schema.$table: NO EXISTE\n";
        }
    }
    echo "\n";
}

// Check if SP exists in both databases
echo "VERIFICANDO SP sp_reporte_general_mercados\n";
echo str_repeat("=", 60) . "\n\n";

try {
    $sp_padron = $pdo_padron->query("SELECT EXISTS (SELECT 1 FROM pg_proc p INNER JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.proname = 'sp_reporte_general_mercados')")->fetchColumn();
    echo ($sp_padron ? "  ✅" : "  ❌") . " SP existe en padron_licencias.public\n";
} catch (PDOException $e) {
    echo "  ❌ Error verificando SP en padron_licencias\n";
}

try {
    $sp_mercados = $pdo_mercados->query("SELECT EXISTS (SELECT 1 FROM pg_proc p INNER JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.proname = 'sp_reporte_general_mercados')")->fetchColumn();
    echo ($sp_mercados ? "  ✅" : "  ❌") . " SP existe en mercados.public\n";
} catch (PDOException $e) {
    echo "  ❌ Error verificando SP en mercados\n";
}
?>
