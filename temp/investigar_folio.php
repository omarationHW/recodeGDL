<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║              INVESTIGANDO ORIGEN DEL FOLIO                     ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// 1. Ver si hay secuencia para folio
echo "1️⃣  Buscando secuencias relacionadas con 'folio'...\n";
$seqs = DB::select("
    SELECT sequence_name, sequence_schema
    FROM information_schema.sequences
    WHERE sequence_schema = 'comun'
    AND sequence_name LIKE '%folio%'
");
if (count($seqs) > 0) {
    foreach ($seqs as $s) {
        echo "   ✅ Secuencia encontrada: " . $s->sequence_schema . "." . $s->sequence_name . "\n";
    }
} else {
    echo "   ❌ No hay secuencias con 'folio'\n";
}

// 2. Ver todas las secuencias en comun
echo "\n2️⃣  Todas las secuencias en esquema 'comun':\n";
$all_seqs = DB::select("
    SELECT sequence_name
    FROM information_schema.sequences
    WHERE sequence_schema = 'comun'
    ORDER BY sequence_name
");
foreach ($all_seqs as $s) {
    echo "   - " . $s->sequence_name . "\n";
}

// 3. Ver estructura del campo folio
echo "\n3️⃣  Estructura del campo 'folio' en tramites:\n";
$col = DB::selectOne("
    SELECT 
        column_name,
        data_type,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'tramites'
    AND column_name = 'folio'
");
echo "   Tipo: " . $col->data_type . "\n";
echo "   Nullable: " . $col->is_nullable . "\n";
echo "   Default: " . ($col->column_default ?: 'NULL - Sin default') . "\n";

// 4. Ver ejemplos de folios existentes
echo "\n4️⃣  Ejemplos de folios en registros existentes:\n";
$ejemplos = DB::select("
    SELECT 
        id_tramite,
        folio,
        tipo_tramite,
        feccap,
        EXTRACT(YEAR FROM feccap) as anio
    FROM comun.tramites
    WHERE folio IS NOT NULL
    ORDER BY id_tramite DESC
    LIMIT 10
");
echo sprintf("   %-10s %-10s %-10s %-15s %s\n", "ID", "FOLIO", "TIPO", "FECHA", "AÑO");
echo "   " . str_repeat("-", 70) . "\n";
foreach ($ejemplos as $e) {
    echo sprintf("   %-10s %-10s %-10s %-15s %s\n", 
        $e->id_tramite,
        $e->folio ?: 'NULL',
        trim($e->tipo_tramite),
        $e->feccap,
        $e->anio
    );
}

// 5. Analizar patrón de folios
echo "\n5️⃣  Analizando patrón de folios:\n";
$stats = DB::selectOne("
    SELECT 
        COUNT(*) as total,
        COUNT(folio) as con_folio,
        MIN(folio) as min_folio,
        MAX(folio) as max_folio
    FROM comun.tramites
");
echo "   Total trámites: " . $stats->total . "\n";
echo "   Con folio: " . $stats->con_folio . "\n";
echo "   Folio MIN: " . ($stats->min_folio ?: 'NULL') . "\n";
echo "   Folio MAX: " . ($stats->max_folio ?: 'NULL') . "\n";

// 6. Buscar tablas de control de folios
echo "\n6️⃣  Buscando tablas de control de folios...\n";
$tablas_folio = DB::select("
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'comun'
    AND (table_name LIKE '%folio%' OR table_name LIKE '%secuencia%' OR table_name LIKE '%consecutivo%')
");
if (count($tablas_folio) > 0) {
    foreach ($tablas_folio as $t) {
        echo "   ✅ Tabla: " . $t->table_name . "\n";
    }
} else {
    echo "   ❌ No se encontraron tablas de control de folios\n";
}

// 7. Buscar SPs relacionados con folio
echo "\n7️⃣  Buscando Stored Procedures con 'folio'...\n";
$sps = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_type = 'FUNCTION'
    AND (routine_name LIKE '%folio%' OR routine_name LIKE '%consecutivo%')
");
if (count($sps) > 0) {
    foreach ($sps as $sp) {
        echo "   ✅ SP: " . $sp->routine_name . "\n";
    }
} else {
    echo "   ❌ No se encontraron SPs relacionados con folio\n";
}

echo "\n✅ Investigación completada\n";
