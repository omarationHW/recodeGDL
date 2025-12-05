<?php
/**
 * Script para desplegar el SP recaudadora_modif_masiva usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_modif_masiva ===\n\n";

$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_modif_masiva.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_modif_masiva.sql\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Tablas origen:\n";
echo "   - comun.reqpredial (3,676,785 registros)\n";
echo "   - comun.reqmultas (403,145 registros)\n";
echo "   - comun.reqlicencias (224,736 registros)\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP desplegado exitosamente\n\n";

    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_modif_masiva'
          AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    } else {
        echo "⚠️  SP no encontrado\n\n";
        exit(1);
    }

    echo "🧪 Probando SP con DATOS REALES:\n\n";

    // Ejemplo 1: Consultar requerimientos prediales (sin modificar)
    echo "=== EJEMPLO 1: Consultar requerimientos prediales ===\n";
    echo "JSON: {\"tipo\":\"predial\",\"recaud\":3,\"folio_ini\":1328820,\"folio_fin\":1328830,\"fecha\":\"2025-01-17\",\"accion\":\"consultar\"}\n\n";

    $result1 = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_modif_masiva(
            '{\"tipo\":\"predial\",\"recaud\":3,\"folio_ini\":1328820,\"folio_fin\":1328830,\"fecha\":\"2025-01-17\",\"accion\":\"consultar\"}'
        )
    ");

    if (count($result1) > 0) {
        foreach ($result1 as $r) {
            echo "Tipo: {$r->tipo_req}\n";
            echo "Registros encontrados: {$r->registros_actualizados}\n";
            echo "Rango de folios: {$r->folio_inicio} - {$r->folio_final}\n";
            echo "Mensaje: {$r->mensaje}\n\n";
        }
    }

    echo str_repeat("=", 80) . "\n\n";

    // Ejemplo 2: Consultar requerimientos de multas (sin modificar)
    echo "=== EJEMPLO 2: Consultar requerimientos de multas ===\n";
    echo "JSON: {\"tipo\":\"multa\",\"recaud\":2,\"folio_ini\":100635,\"folio_fin\":100650,\"fecha\":\"2024-04-29\",\"accion\":\"consultar\"}\n\n";

    $result2 = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_modif_masiva(
            '{\"tipo\":\"multa\",\"recaud\":2,\"folio_ini\":100635,\"folio_fin\":100650,\"fecha\":\"2024-04-29\",\"accion\":\"consultar\"}'
        )
    ");

    if (count($result2) > 0) {
        foreach ($result2 as $r) {
            echo "Tipo: {$r->tipo_req}\n";
            echo "Registros encontrados: {$r->registros_actualizados}\n";
            echo "Rango de folios: {$r->folio_inicio} - {$r->folio_final}\n";
            echo "Mensaje: {$r->mensaje}\n\n";
        }
    }

    echo str_repeat("=", 80) . "\n\n";

    // Ejemplo 3: Consultar requerimientos de licencias (sin modificar)
    echo "=== EJEMPLO 3: Consultar requerimientos de licencias ===\n";
    echo "JSON: {\"tipo\":\"licencia\",\"recaud\":2,\"folio_ini\":28745,\"folio_fin\":28755,\"fecha\":\"2024-01-01\",\"accion\":\"consultar\"}\n\n";

    $result3 = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_modif_masiva(
            '{\"tipo\":\"licencia\",\"recaud\":2,\"folio_ini\":28745,\"folio_fin\":28755,\"fecha\":\"2024-01-01\",\"accion\":\"consultar\"}'
        )
    ");

    if (count($result3) > 0) {
        foreach ($result3 as $r) {
            echo "Tipo: {$r->tipo_req}\n";
            echo "Registros encontrados: {$r->registros_actualizados}\n";
            echo "Rango de folios: {$r->folio_inicio} - {$r->folio_final}\n";
            echo "Mensaje: {$r->mensaje}\n\n";
        }
    }

    echo str_repeat("=", 80) . "\n\n";

    echo "✅ Despliegue completado exitosamente\n";
    echo "\n📋 RESUMEN:\n";
    echo "✓ SP: multas_reglamentos.recaudadora_modif_masiva\n";
    echo "✓ Tablas: comun.reqpredial, comun.reqmultas, comun.reqlicencias\n";
    echo "✓ Funcionalidad: Modificación masiva de requerimientos por rango\n";
    echo "✓ Acciones disponibles: consultar, modificar, cancelar\n";
    echo "\n🎯 PRÓXIMO PASO:\n";
    echo "Abre: http://localhost:3000/multas_reglamentos/ModifMasiva\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
