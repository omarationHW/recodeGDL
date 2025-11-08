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
    'schema' => 'public',
]]);
DB::reconnect('pgsql');

echo "=== ESTRUCTURA DE public.saldos_lic ===\n\n";

$columns = DB::select("
    SELECT
        column_name,
        data_type,
        character_maximum_length,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'saldos_lic'
    ORDER BY ordinal_position
");

echo "Columnas de public.saldos_lic:\n\n";
foreach ($columns as $col) {
    $type = $col->data_type;
    if ($col->character_maximum_length) {
        $type .= "({$col->character_maximum_length})";
    }
    $nullable = $col->is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
    $default = $col->column_default ? " DEFAULT {$col->column_default}" : '';

    echo "  • {$col->column_name} - {$type} {$nullable}{$default}\n";
}

// También ver una muestra de datos
echo "\nMuestra de datos (primeras 3 filas):\n";
try {
    $sample = DB::select("SELECT * FROM public.saldos_lic LIMIT 3");

    if (count($sample) > 0) {
        echo "\nRegistros encontrados: " . count($sample) . "\n";
        foreach ($sample as $row) {
            echo "\n" . json_encode($row, JSON_PRETTY_PRINT) . "\n";
        }
    } else {
        echo "  (tabla vacía)\n";
    }
} catch (\Exception $e) {
    echo "  Error al leer datos: " . $e->getMessage() . "\n";
}
