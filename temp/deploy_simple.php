<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "\n=== Deploy sp_reactivar_tramite ===\n\n";

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

echo "✓ Conexión establecida\n";

$sql = file_get_contents(__DIR__ . '/deploy_sp_reactivar.sql');

try {
    DB::unprepared($sql);
    echo "✓ SP creado exitosamente\n\n";

    // Verificar
    $result = DB::select("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name = 'sp_reactivar_tramite'
    ");

    if (count($result) > 0) {
        echo "✓ Verificado: comun.sp_reactivar_tramite existe\n";
    } else {
        echo "✗ ERROR: SP no encontrado después de crear\n";
    }
} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
}

echo "\n";
