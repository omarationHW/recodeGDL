<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_extractos_rpt ===\n\n";

$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_extractos_rpt.sql';
$sql = file_get_contents($sql_file);

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_extractos_rpt desplegado exitosamente\n\n";

    // Verificar
    $sp_info = DB::connection('pgsql')->select("
        SELECT n.nspname as schema, p.proname as name
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_extractos_rpt' AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        echo "✅ SP encontrado: multas_reglamentos.recaudadora_extractos_rpt\n\n";
    }

    // Buscar una cuenta de ejemplo
    echo "🔍 Buscando cuenta de ejemplo...\n";
    $cuentas = DB::connection('pgsql')->select("
        SELECT cuenta, cvecatnva, saldo 
        FROM catastro_gdl.controladora 
        WHERE cuenta IS NOT NULL AND saldo > 0
        LIMIT 3
    ");

    if (count($cuentas) > 0) {
        echo "Cuentas de ejemplo encontradas:\n";
        foreach ($cuentas as $c) {
            echo "  - Cuenta: {$c->cuenta} | Clave: {$c->cvecatnva} | Saldo: \${$c->saldo}\n";
        }
        echo "\n";
    }

    // Pruebas
    echo "🧪 Probando el SP:\n\n";

    if (count($cuentas) > 0) {
        $cuenta_ejemplo = $cuentas[0]->cuenta;
        
        echo "=== EJEMPLO 1: Cuenta válida ($cuenta_ejemplo) ===\n";
        $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_extractos_rpt(?)", [$cuenta_ejemplo]);
        if (count($result) > 0) {
            $r = $result[0];
            echo "Success: " . ($r->success ? 'Sí' : 'No') . "\n";
            echo "Message: {$r->message}\n";
            echo "Cuenta: {$r->cuenta}\n";
            echo "Clave Catastral: {$r->clave_catastral}\n";
            echo "Total Adeudo: \${$r->total_adeudo}\n";
            echo "Fecha: {$r->fecha_extracto}\n";
        }
    }

    echo "\n=== EJEMPLO 2: Cuenta inexistente (99999999) ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_extractos_rpt('99999999')");
    if (count($result) > 0) {
        $r = $result[0];
        echo "Success: " . ($r->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$r->message}\n";
    }

    echo "\n=== EJEMPLO 3: Cuenta inválida (texto) ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_extractos_rpt('ABC123')");
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
