<?php
/**
 * Script para desplegar el SP recaudadora_estadreq usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_estadreq ===\n\n";

$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_estadreq.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_estadreq.sql\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Base de datos: padron_licencias\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_estadreq desplegado exitosamente\n\n";

    // Verificar existencia
    $sp_info = DB::connection('pgsql')->select("
        SELECT n.nspname as schema, p.proname as name,
               pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_estadreq' AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    }

    // Probar el SP
    echo "🧪 Probando el SP:\n\n";

    echo "=== EJEMPLO 1: Todos los ejecutores (primeros 5) ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_estadreq('') LIMIT 5");

    echo "Total encontrado: " . count($result) . "\n";
    foreach ($result as $i => $row) {
        $num = $i + 1;
        echo "$num. {$row->ejecutor} (ID: {$row->id_ejecutor}) - CVE: {$row->cve_ejecutor} - Categoría: {$row->categoria}\n";
    }

    echo "\n=== EJEMPLO 2: Filtrar por 'ACEVES' ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_estadreq('ACEVES') LIMIT 5");

    echo "Total encontrado: " . count($result) . "\n";
    foreach ($result as $i => $row) {
        $num = $i + 1;
        echo "$num. {$row->ejecutor} - Oficio: {$row->oficio}\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
