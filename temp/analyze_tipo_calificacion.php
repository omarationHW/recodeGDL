<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Analizando catastro_gdl.tipo_calificacion_multa...\n\n";

try {
    // Obtener 5 ejemplos con detalles
    $samples = DB::connection('pgsql')->select("
        SELECT *
        FROM catastro_gdl.tipo_calificacion_multa
        ORDER BY id_control DESC
        LIMIT 5
    ");

    if (count($samples) > 0) {
        echo "📊 EJEMPLOS DE DATOS REALES:\n\n";

        foreach ($samples as $i => $sample) {
            if ($i >= 3) break;

            echo "═════════════════════════════════════════════════════════════\n";
            echo "EJEMPLO " . ($i + 1) . ":\n";
            echo "═════════════════════════════════════════════════════════════\n";

            $data = (array)$sample;
            foreach ($data as $key => $value) {
                $val = $value ?? 'NULL';
                echo "  {$key}: {$val}\n";
            }
            echo "\n";
        }

        // Extraer IDs de multa para buscar más información
        $idMultas = array_map(fn($s) => $s->id_multa, array_slice($samples, 0, 3));

        echo "═══════════════════════════════════════════════════════════\n";
        echo "🔍 Buscando información de las multas...\n";
        echo "═══════════════════════════════════════════════════════════\n\n";

        // Buscar tablas de multas
        $multasTable = null;
        $possibleTables = ['catastro_gdl.multas', 'comun.multas', 'catastro_gdl.ta08_multas'];

        foreach ($possibleTables as $table) {
            try {
                $test = DB::connection('pgsql')->select("SELECT 1 FROM $table LIMIT 1");
                $multasTable = $table;
                echo "✅ Tabla de multas encontrada: $table\n\n";
                break;
            } catch (Exception $e) {
                // Tabla no existe
            }
        }

        if ($multasTable) {
            foreach ($idMultas as $idx => $idMulta) {
                try {
                    $multa = DB::connection('pgsql')->selectOne("
                        SELECT *
                        FROM $multasTable
                        WHERE cvemul = ?
                        LIMIT 1
                    ", [$idMulta]);

                    if ($multa) {
                        echo "Multa ID {$idMulta}:\n";
                        $data = (array)$multa;
                        $c = 0;
                        foreach ($data as $key => $value) {
                            if ($c >= 8) break;
                            if (stripos($key, 'cuenta') !== false || stripos($key, 'folio') !== false ||
                                stripos($key, 'importe') !== false || stripos($key, 'fecha') !== false) {
                                $val = $value ?? 'NULL';
                                if (strlen($val) > 50) $val = substr($val, 0, 50) . '...';
                                echo "  {$key}: {$val}\n";
                                $c++;
                            }
                        }
                        echo "\n";
                    }
                } catch (Exception $e) {
                    // Ignorar
                }
            }
        }

        // Estadísticas
        echo "═══════════════════════════════════════════════════════════\n";
        echo "📊 ESTADÍSTICAS:\n";
        echo "═══════════════════════════════════════════════════════════\n\n";

        $stats = DB::connection('pgsql')->selectOne("
            SELECT
                COUNT(*) as total,
                COUNT(DISTINCT id_multa) as multas_unicas,
                COUNT(DISTINCT tipo_calificacion) as tipos_distintos,
                MIN(fecha_actual) as fecha_min,
                MAX(fecha_actual) as fecha_max
            FROM catastro_gdl.tipo_calificacion_multa
        ");

        echo "Total registros: {$stats->total}\n";
        echo "Multas únicas: {$stats->multas_unicas}\n";
        echo "Tipos distintos: {$stats->tipos_distintos}\n";
        echo "Fecha mínima: {$stats->fecha_min}\n";
        echo "Fecha máxima: {$stats->fecha_max}\n\n";

        // Ver tipos de calificación
        $tipos = DB::connection('pgsql')->select("
            SELECT tipo_calificacion, COUNT(*) as total
            FROM catastro_gdl.tipo_calificacion_multa
            GROUP BY tipo_calificacion
            ORDER BY total DESC
            LIMIT 10
        ");

        echo "Tipos de calificación:\n";
        foreach ($tipos as $tipo) {
            echo "  • {$tipo->tipo_calificacion}: {$tipo->total} registros\n";
        }

        // Obtener 3 ejemplos de IDs de multa para probar
        echo "\n╔════════════════════════════════════════════════════════════╗\n";
        echo "║           📋 IDS DE MULTA PARA PROBAR                     ║\n";
        echo "╚════════════════════════════════════════════════════════════╝\n\n";

        foreach ($samples as $i => $s) {
            if ($i >= 3) break;
            echo "Ejemplo " . ($i + 1) . ": ID Multa = {$s->id_multa}\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
