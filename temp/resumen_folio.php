<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║                  ANÁLISIS COMPLETO DE FOLIOS                   ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// 1. Estadísticas generales
$stats = DB::selectOne("
    SELECT 
        COUNT(*) as total_tramites,
        COUNT(folio) as tramites_con_folio,
        COUNT(CASE WHEN folio IS NULL THEN 1 END) as tramites_sin_folio,
        MIN(id_tramite) as primer_id,
        MAX(id_tramite) as ultimo_id
    FROM comun.tramites
");

echo "📊 ESTADÍSTICAS DE TRÁMITES:\n";
echo "   Total de trámites en BD: " . number_format($stats->total_tramites) . "\n";
echo "   Trámites CON folio: " . number_format($stats->tramites_con_folio) . "\n";
echo "   Trámites SIN folio: " . number_format($stats->tramites_sin_folio) . "\n";
echo "   Rango de IDs: " . $stats->primer_id . " - " . $stats->ultimo_id . "\n\n";

$porcentaje = ($stats->tramites_con_folio / $stats->total_tramites) * 100;
echo "   📈 Porcentaje con folio: " . number_format($porcentaje, 2) . "%\n\n";

// 2. Estructura del campo
echo "🔍 ESTRUCTURA DEL CAMPO 'folio':\n";
$col = DB::selectOne("
    SELECT 
        data_type,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'tramites'
    AND column_name = 'folio'
");

echo "   Tipo de dato: " . $col->data_type . "\n";
echo "   Permite NULL: " . $col->is_nullable . "\n";
echo "   Valor por defecto: " . ($col->column_default ?: 'NULL (sin default)') . "\n";
echo "   Secuencia automática: " . (strpos($col->column_default ?: '', 'nextval') !== false ? 'SÍ' : 'NO') . "\n\n";

// 3. Conclusión
echo "💡 CONCLUSIÓN:\n";
if ($stats->tramites_con_folio == 0) {
    echo "   ❌ El sistema NO utiliza folios para trámites de licencias\n";
    echo "   ✅ Se usa únicamente el campo 'id_tramite' como identificador\n";
    echo "   ℹ️  El campo 'folio' existe en la estructura pero NO se usa\n\n";
    
    echo "📋 RECOMENDACIÓN:\n";
    echo "   Opción 1: Dejar folio en NULL (comportamiento actual del sistema)\n";
    echo "   Opción 2: Crear secuencia nueva si se requiere implementar folios\n";
    echo "   Opción 3: Usar id_tramite como folio (copiar el valor)\n";
} else {
    echo "   ✅ El sistema SÍ utiliza folios\n";
    echo "   Se debe implementar lógica de generación\n";
}
