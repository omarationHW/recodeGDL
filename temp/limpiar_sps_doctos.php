<?php
/**
 * Limpiar todas las funciones sp_doctos* antes de redeployar
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== LIMPIEZA DE SPs DOCTOS ===\n";

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

echo "Obteniendo lista de funciones sp_doctos*...\n";

// Obtener todas las funciones con sus firmas completas
$functions = DB::select("
    SELECT
        p.proname as name,
        pg_get_function_identity_arguments(p.oid) as args,
        n.nspname as schema
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'sp_doctos%'
");

echo "Funciones encontradas: " . count($functions) . "\n\n";

foreach ($functions as $func) {
    $signature = "{$func->schema}.{$func->name}({$func->args})";
    echo "Eliminando: $signature\n";

    try {
        DB::statement("DROP FUNCTION IF EXISTS {$signature}");
        echo "  ✓ Eliminada\n";
    } catch (\Exception $e) {
        echo "  ✗ Error: " . $e->getMessage() . "\n";
    }
}

echo "\nVerificando que se eliminaron todas...\n";
$remaining = DB::select("
    SELECT count(*) as count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'sp_doctos%'
");

if ($remaining[0]->count == 0) {
    echo "✓✓✓ Todas las funciones sp_doctos* han sido eliminadas\n";
} else {
    echo "⚠ WARNING: Aún quedan {$remaining[0]->count} funciones\n";
}
