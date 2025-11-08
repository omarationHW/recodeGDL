<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => [
    'driver' => 'pgsql',
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'padron_licencias',
    'username' => 'refact',
    'password' => 'FF)-BQk2',
    'charset' => 'utf8',
    'prefix' => '',
    'schema' => 'comun',
]]);
DB::reconnect('pgsql');

echo "=== VERIFICACIÓN DE TABLAS DE SALDOS ===\n\n";

// Buscar tablas relacionadas con saldos
$tables = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'public')
    AND table_name LIKE '%saldo%'
    ORDER BY table_schema, table_name
");

echo "Tablas encontradas relacionadas con 'saldo': " . count($tables) . "\n\n";
foreach ($tables as $table) {
    echo "  ✓ {$table->table_schema}.{$table->table_name}\n";
}

// Buscar tablas relacionadas con detsal
echo "\nTablas relacionadas con 'detsal':\n";
$detsal_tables = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'public')
    AND table_name LIKE '%detsal%'
    ORDER BY table_schema, table_name
");

foreach ($detsal_tables as $table) {
    echo "  ✓ {$table->table_schema}.{$table->table_name}\n";
}

// Verificar si existe lic_cancel
echo "\nTabla lic_cancel:\n";
$lic_cancel = DB::select("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'public')
    AND table_name = 'lic_cancel'
");

if (count($lic_cancel) > 0) {
    foreach ($lic_cancel as $table) {
        echo "  ✓ {$table->table_schema}.{$table->table_name} - EXISTE\n";
    }
} else {
    echo "  ✗ lic_cancel NO EXISTE\n";
}
