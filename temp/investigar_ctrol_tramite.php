<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║         INVESTIGANDO TABLA CTROL_REG_TRAMITE                   ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// 1. Ver estructura de la tabla
echo "1️⃣  Estructura de ctrol_reg_tramite:\n";
$cols = DB::select("
    SELECT column_name, data_type, character_maximum_length, column_default
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'ctrol_reg_tramite'
    ORDER BY ordinal_position
");

foreach ($cols as $col) {
    $type = $col->data_type;
    if ($col->character_maximum_length) {
        $type .= "({$col->character_maximum_length})";
    }
    echo sprintf("   %-25s %-20s %s\n", $col->column_name, $type, $col->column_default ?: '');
}

// 2. Ver datos de ejemplo
echo "\n2️⃣  Datos de ejemplo en ctrol_reg_tramite:\n";
$ejemplos = DB::select("SELECT * FROM comun.ctrol_reg_tramite LIMIT 5");
if (count($ejemplos) > 0) {
    echo "   Total registros: " . DB::selectOne("SELECT COUNT(*) as total FROM comun.ctrol_reg_tramite")->total . "\n\n";
    foreach ($ejemplos as $e) {
        echo "   Registro:\n";
        foreach ((array)$e as $key => $val) {
            echo "      $key: " . ($val ?: 'NULL') . "\n";
        }
        echo "\n";
    }
} else {
    echo "   ❌ Tabla vacía\n";
}

// 3. Ver valor de secuencia
echo "\n3️⃣  Secuencia ctrol_reg_tramite_folio_control_seq:\n";
try {
    $seq = DB::selectOne("SELECT last_value FROM comun.ctrol_reg_tramite_folio_control_seq");
    echo "   Último valor: " . $seq->last_value . "\n";
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
}
