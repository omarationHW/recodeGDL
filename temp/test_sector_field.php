<?php
chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "DIAGNÓSTICO: Campo 'sector' no retorna valor\n";
echo "==============================================\n\n";

try {
    // 1. Consulta directa a la tabla
    echo "1. Consultando directamente en la tabla...\n";
    $direct = DB::connection('pgsql')->selectOne("
        SELECT 
            id_local,
            oficina,
            num_mercado,
            categoria,
            seccion,
            local,
            letra_local,
            sector,
            LENGTH(sector) as sector_length,
            ASCII(sector) as sector_ascii
        FROM publico.ta_11_locales
        WHERE oficina = 1
          AND num_mercado = 2
          AND categoria = 1
          AND seccion = 'SS'
          AND local = 3
        LIMIT 1
    ");

    if ($direct) {
        echo "   ✓ Local encontrado (consulta directa)\n";
        echo "   id_local: {$direct->id_local}\n";
        echo "   sector: '{$direct->sector}'\n";
        echo "   sector length: {$direct->sector_length}\n";
        echo "   sector ASCII: {$direct->sector_ascii}\n";
        
        if (empty(trim($direct->sector))) {
            echo "   ⚠️ PROBLEMA: sector está vacío o solo contiene espacios\n";
        }
    } else {
        echo "   ✗ Local no encontrado\n";
    }

    echo "\n2. Consultando via SP sp_localesmodif_buscar_local...\n";
    $sp = DB::connection('pgsql')->select("
        SELECT * FROM sp_localesmodif_buscar_local(1, 2, 1, 'SS', 3, '', '')
    ");

    if (!empty($sp)) {
        echo "   ✓ SP retornó resultados\n";
        $local = $sp[0];
        echo "   id_local: {$local->id_local}\n";
        echo "   sector: '{$local->sector}'\n";
        
        // Verificar todos los campos
        echo "\n   Campos retornados:\n";
        foreach ($local as $key => $value) {
            $val = $value === null ? 'NULL' : "'{$value}'";
            echo "     {$key}: {$val}\n";
        }
    } else {
        echo "   ✗ SP no retornó resultados\n";
    }

    echo "\n3. Verificando definición del SP...\n";
    $spDef = DB::connection('pgsql')->selectOne("
        SELECT routine_definition
        FROM information_schema.routines
        WHERE routine_name = 'sp_localesmodif_buscar_local'
    ");

    if ($spDef && strpos($spDef->routine_definition, 'l.sector') !== false) {
        echo "   ✓ SP incluye l.sector en el SELECT\n";
        
        // Buscar el casting
        if (strpos($spDef->routine_definition, 'sector::text') !== false) {
            echo "   ✓ SP usa casting: sector::text\n";
        } else {
            echo "   ⚠️ SP NO usa casting para sector\n";
        }
    } else {
        echo "   ✗ SP NO incluye l.sector en el SELECT\n";
    }

    echo "\n==============================================\n";
    echo "DIAGNÓSTICO COMPLETO\n";
    echo "==============================================\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
}
