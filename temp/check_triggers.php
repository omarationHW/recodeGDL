<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║       VERIFICANDO TRIGGERS EN COMUN.TRAMITES                   ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

$triggers = DB::select("
    SELECT
        trigger_name,
        event_manipulation,
        action_timing,
        action_statement
    FROM information_schema.triggers
    WHERE event_object_schema = 'comun'
    AND event_object_table = 'tramites'
");

if (count($triggers) > 0) {
    echo "⚠️  TRIGGERS ENCONTRADOS: " . count($triggers) . "\n\n";
    foreach ($triggers as $t) {
        echo "Trigger: " . $t->trigger_name . "\n";
        echo "  Evento: " . $t->event_manipulation . " " . $t->action_timing . "\n";
        echo "  Acción: " . substr($t->action_statement, 0, 200) . "...\n\n";
    }
} else {
    echo "✅ No hay triggers en la tabla tramites\n";
}

// Verificar secuencia del id_tramite
echo "\n📊 Verificando secuencia de id_tramite...\n";
$seqs = DB::select("
    SELECT
        c.column_name,
        c.column_default
    FROM information_schema.columns c
    WHERE c.table_schema = 'comun'
    AND c.table_name = 'tramites'
    AND c.column_name IN ('id_tramite', 'folio')
");

foreach ($seqs as $s) {
    echo $s->column_name . ": " . ($s->column_default ?: 'No default') . "\n";
}
