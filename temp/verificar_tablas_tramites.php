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

echo "=== TABLAS RELACIONADAS CON TRÁMITES ===\n\n";

// Buscar tablas con "tramite" en el nombre
$tables_comun = DB::select("
    SELECT table_name, table_schema
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'public')
    AND table_name LIKE '%tramite%'
    ORDER BY table_schema, table_name
");

echo "Tablas con 'tramite' en el nombre:\n";
foreach ($tables_comun as $table) {
    echo "  • {$table->table_schema}.{$table->table_name}\n";
}

// Buscar tablas con "bloque" en el nombre
echo "\nTablas con 'bloque' en el nombre:\n";
$tables_bloqueo = DB::select("
    SELECT table_name, table_schema
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'public')
    AND table_name LIKE '%bloque%'
    ORDER BY table_schema, table_name
");

foreach ($tables_bloqueo as $table) {
    echo "  • {$table->table_schema}.{$table->table_name}\n";
}

// Ver estructura de tramites si existe
echo "\n=== ESTRUCTURA DE comun.tramites (si existe) ===\n";
try {
    $columns = DB::select("
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'tramites'
        ORDER BY ordinal_position
    ");

    if (count($columns) > 0) {
        foreach ($columns as $col) {
            echo "  • {$col->column_name} ({$col->data_type}) " . ($col->is_nullable === 'YES' ? 'NULL' : 'NOT NULL') . "\n";
        }
    } else {
        echo "  (tabla no existe)\n";
    }
} catch (\Exception $e) {
    echo "  Error: " . $e->getMessage() . "\n";
}
