<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║       RESETEANDO SECUENCIA DE ID_TRAMITE                       ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// 1. Ver estado actual
echo "1️⃣  Estado actual de la secuencia:\n";
$current = DB::selectOne("SELECT nextval('tramites_id_tramite_seq') as next_val");
echo "   Siguiente valor actual: " . $current->next_val . "\n\n";

// 2. Ver MAX ID en tabla
echo "2️⃣  MAX ID en la tabla tramites:\n";
$max = DB::selectOne("SELECT MAX(id_tramite) as max_id FROM comun.tramites");
echo "   MAX ID: " . $max->max_id . "\n\n";

// 3. Resetear la secuencia
$nuevo_valor = $max->max_id + 1;
echo "3️⃣  Reseteando secuencia a " . $nuevo_valor . "...\n";
DB::statement("SELECT setval('tramites_id_tramite_seq', ?, false)", [$nuevo_valor]);
echo "   ✅ Secuencia reseteada\n\n";

// 4. Verificar
echo "4️⃣  Verificando nuevo valor:\n";
$new_next = DB::selectOne("SELECT currval('tramites_id_tramite_seq') as curr_val");
echo "   Valor actual de secuencia: " . $new_next->curr_val . "\n";
echo "   Próximo ID que se asignará: " . ($new_next->curr_val + 1) . "\n\n";

echo "✅ Secuencia corregida exitosamente\n";
echo "   Los próximos registros usarán IDs >= " . ($new_next->curr_val + 1) . "\n";
