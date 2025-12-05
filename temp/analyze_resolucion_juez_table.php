<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Analizando tabla catastro_gdl.resolucion_juez...\n\n";

try {
    // Estructura completa
    echo "📊 Estructura de la tabla:\n\n";

    $columns = DB::connection('pgsql')->select("
        SELECT
            column_name,
            data_type,
            udt_name,
            character_maximum_length,
            numeric_precision
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'resolucion_juez'
        ORDER BY ordinal_position
    ");

    foreach ($columns as $col) {
        echo "  {$col->column_name}:\n";
        echo "    tipo: {$col->data_type} ({$col->udt_name})\n";
        if ($col->character_maximum_length) {
            echo "    long: {$col->character_maximum_length}\n";
        }
        if ($col->numeric_precision) {
            echo "    precision: {$col->numeric_precision}\n";
        }
        echo "\n";
    }

    // Obtener 5 ejemplos completos
    echo "\n📝 Ejemplos de datos:\n\n";

    $ejemplos = DB::connection('pgsql')->select("
        SELECT * FROM catastro_gdl.resolucion_juez
        ORDER BY id_resolucion DESC
        LIMIT 5
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "═════════════════════════════════════════════════════════════\n";
        echo "EJEMPLO " . ($i + 1) . ":\n";
        echo "═════════════════════════════════════════════════════════════\n";

        $data = (array)$ej;
        foreach ($data as $key => $value) {
            $displayValue = $value ?? 'NULL';
            if (strlen($displayValue) > 50) {
                $displayValue = substr($displayValue, 0, 50) . '...';
            }
            echo "  {$key}: {$displayValue}\n";
        }
        echo "\n";
    }

    // Estadísticas
    echo "\n📈 Estadísticas:\n\n";

    $stats = DB::connection('pgsql')->selectOne("
        SELECT
            COUNT(*) as total,
            COUNT(DISTINCT cvecuenta) as cuentas_unicas,
            MIN(axoini) as anio_min,
            MAX(axofin) as anio_max,
            COUNT(CASE WHEN vigencia = 'A' THEN 1 END) as activos,
            COUNT(CASE WHEN vigencia = 'C' THEN 1 END) as cancelados
        FROM catastro_gdl.resolucion_juez
    ");

    echo "  Total resoluciones: {$stats->total}\n";
    echo "  Cuentas únicas: {$stats->cuentas_unicas}\n";
    echo "  Año mínimo: {$stats->anio_min}\n";
    echo "  Año máximo: {$stats->anio_max}\n";
    echo "  Activos: {$stats->activos}\n";
    echo "  Cancelados: {$stats->cancelados}\n";

    // Buscar si hay una tabla relacionada con folio
    echo "\n\n🔗 Buscando relación con otras tablas...\n\n";

    // Ver si resoluciones tiene folio
    $resoluciones = DB::connection('pgsql')->select("
        SELECT * FROM catastro_gdl.resoluciones LIMIT 2
    ");

    if (count($resoluciones) > 0) {
        echo "✓ Tabla catastro_gdl.resoluciones:\n";
        foreach ($resoluciones as $r) {
            $data = (array)$r;
            foreach ($data as $key => $value) {
                echo "  {$key}: " . ($value ?? 'NULL') . "\n";
            }
            echo "\n";
        }
    }

    // Ver req_resolucion
    echo "\n✓ Tabla catastro_gdl.req_resolucion (relación con requerimientos):\n";
    $reqResol = DB::connection('pgsql')->select("
        SELECT * FROM catastro_gdl.req_resolucion LIMIT 3
    ");

    foreach ($reqResol as $r) {
        $data = (array)$r;
        $preview = [];
        foreach ($data as $key => $value) {
            $preview[] = "$key=" . ($value ?? 'NULL');
        }
        echo "  " . implode(', ', $preview) . "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
