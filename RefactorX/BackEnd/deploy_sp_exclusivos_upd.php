<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_exclusivos_upd ===\n\n";

$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_exclusivos_upd.sql';
$sql = file_get_contents($sql_file);

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_exclusivos_upd desplegado exitosamente\n\n";

    // Verificar
    $sp_info = DB::connection('pgsql')->select("
        SELECT n.nspname as schema, p.proname as name
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_exclusivos_upd' AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        echo "✅ SP encontrado: multas_reglamentos.recaudadora_exclusivos_upd\n\n";
    }

    // Pruebas
    echo "🧪 Probando el SP:\n\n";

    echo "=== EJEMPLO 1: Actualizar (ID: 123) ===\n";
    $json = json_encode(['id' => 123, 'accion' => 'actualizar', 'campo' => 'estatus', 'valor' => 'activo']);
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_exclusivos_upd(?)", [$json]);
    if (count($result) > 0) {
        $r = $result[0];
        echo "Success: " . ($r->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$r->message}\n";
        echo "Registros: {$r->registros_procesados}\n";
    }

    echo "\n=== EJEMPLO 2: Consultar (ID: 456) ===\n";
    $json = json_encode(['id' => 456, 'accion' => 'consultar']);
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_exclusivos_upd(?)", [$json]);
    if (count($result) > 0) {
        $r = $result[0];
        echo "Success: " . ($r->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$r->message}\n";
    }

    echo "\n=== EJEMPLO 3: Eliminar (ID: 789) ===\n";
    $json = json_encode(['id' => 789, 'accion' => 'eliminar']);
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_exclusivos_upd(?)", [$json]);
    if (count($result) > 0) {
        $r = $result[0];
        echo "Success: " . ($r->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$r->message}\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
