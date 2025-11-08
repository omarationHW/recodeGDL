<?php
// INVESTIGAR LENTITUD EN CARGA DE LICENCIAS

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "<pre>";
echo "====================================\n";
echo "INVESTIGANDO LENTITUD EN LICENCIAS\n";
echo "====================================\n\n";

try {
    DB::purge('pgsql');
    config(['database.connections.pgsql.database' => 'padron_licencias']);
    DB::reconnect('pgsql');

    echo "Conectado a: " . DB::connection()->getDatabaseName() . "\n\n";

    // Test 1: Contar licencias vigentes
    echo "TEST 1: Contando licencias vigentes...\n";
    $start = microtime(true);
    $count = DB::select("SELECT COUNT(*) as total FROM comun.licencias WHERE vigente = 'V'");
    $time = (microtime(true) - $start) * 1000;
    echo "Total licencias vigentes: " . $count[0]->total . " (" . round($time, 2) . "ms)\n\n";

    // Test 2: Verificar índices
    echo "TEST 2: Verificando índices en comun.licencias...\n";
    $indices = DB::select("
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun' AND tablename = 'licencias'
    ");
    foreach ($indices as $idx) {
        echo "  - {$idx->indexname}\n";
    }
    echo "\n";

    // Test 3: Query sin DISTINCT
    echo "TEST 3: Licencias disponibles SIN DISTINCT (grupo_id=1)...\n";
    $start = microtime(true);
    $result = DB::select("
        SELECT l.licencia, l.propietario::TEXT, l.actividad::TEXT, l.id_giro
        FROM comun.licencias l
        WHERE l.licencia NOT IN (SELECT d.licencia FROM public.lic_detgrupo d WHERE d.lic_grupos_id = 1)
          AND l.vigente = 'V'
        LIMIT 1000
    ");
    $time = (microtime(true) - $start) * 1000;
    echo "Resultados: " . count($result) . " (" . round($time, 2) . "ms)\n\n";

    // Test 4: Query con DISTINCT
    echo "TEST 4: Licencias disponibles CON DISTINCT (grupo_id=1)...\n";
    $start = microtime(true);
    $result = DB::select("
        SELECT DISTINCT ON (l.licencia) l.licencia, l.propietario::TEXT, l.actividad::TEXT, l.id_giro
        FROM comun.licencias l
        WHERE l.licencia NOT IN (SELECT d.licencia FROM public.lic_detgrupo d WHERE d.lic_grupos_id = 1)
          AND l.vigente = 'V'
        ORDER BY l.licencia, l.actividad
        LIMIT 1000
    ");
    $time = (microtime(true) - $start) * 1000;
    echo "Resultados: " . count($result) . " (" . round($time, 2) . "ms)\n\n";

    // Test 5: Subquery optimizada con LEFT JOIN
    echo "TEST 5: Licencias disponibles con LEFT JOIN (más rápido)...\n";
    $start = microtime(true);
    $result = DB::select("
        SELECT DISTINCT ON (l.licencia)
          l.licencia,
          l.propietario::TEXT,
          l.actividad::TEXT,
          l.id_giro
        FROM comun.licencias l
        LEFT JOIN public.lic_detgrupo d ON d.licencia = l.licencia AND d.lic_grupos_id = 1
        WHERE l.vigente = 'V'
          AND d.licencia IS NULL
        ORDER BY l.licencia, l.actividad
        LIMIT 1000
    ");
    $time = (microtime(true) - $start) * 1000;
    echo "Resultados: " . count($result) . " (" . round($time, 2) . "ms)\n\n";

    // Test 6: Contar licencias en lic_detgrupo
    echo "TEST 6: Verificando tabla lic_detgrupo...\n";
    $start = microtime(true);
    $count = DB::select("SELECT COUNT(*) as total FROM public.lic_detgrupo");
    $time = (microtime(true) - $start) * 1000;
    echo "Total registros en lic_detgrupo: " . $count[0]->total . " (" . round($time, 2) . "ms)\n\n";

    // Test 7: Verificar índices en lic_detgrupo
    echo "TEST 7: Verificando índices en lic_detgrupo...\n";
    $indices = DB::select("
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = 'lic_detgrupo'
    ");
    if (count($indices) > 0) {
        foreach ($indices as $idx) {
            echo "  - {$idx->indexname}\n";
        }
    } else {
        echo "  ⚠️ NO HAY ÍNDICES EN lic_detgrupo - ESTO CAUSA LENTITUD\n";
    }
    echo "\n";

    // Test 8: Giros tipo L
    echo "TEST 8: Cargando giros tipo 'L'...\n";
    $start = microtime(true);
    $giros = DB::select("SELECT id_giro, descripcion::TEXT FROM comun.c_giros WHERE tipo = 'L' ORDER BY descripcion");
    $time = (microtime(true) - $start) * 1000;
    echo "Total giros: " . count($giros) . " (" . round($time, 2) . "ms)\n\n";

    echo "====================================\n";
    echo "ANÁLISIS COMPLETADO\n";
    echo "====================================\n\n";

    echo "RECOMENDACIONES:\n";
    echo "1. Si lic_detgrupo no tiene índices, créalos\n";
    echo "2. Usa LEFT JOIN en lugar de NOT IN para mejor performance\n";
    echo "3. Limita resultados iniciales a 500-1000 registros\n";
    echo "4. Considera paginación en el backend\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}

echo "</pre>";
