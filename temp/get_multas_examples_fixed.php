<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Obteniendo ejemplos de multas con calificación...\n\n";

try {
    // Obtener ejemplos con JOIN correcto
    $examples = DB::connection('pgsql')->select("
        SELECT
            m.id_multa,
            m.num_acta as folio,
            m.contribuyente,
            m.domicilio,
            m.calificacion,
            m.multa,
            m.total,
            m.fecha_acta,
            tc.tipo_calificacion,
            tc.usuario as usuario_calificacion,
            tc.fecha_actual as fecha_calificacion
        FROM catastro_gdl.multas m
        INNER JOIN catastro_gdl.tipo_calificacion_multa tc ON tc.id_multa = m.id_multa
        WHERE m.id_multa IN (415267, 415189, 415266)
        ORDER BY m.id_multa DESC
    ");

    if (count($examples) > 0) {
        echo "📊 EJEMPLOS DE DATOS REALES:\n\n";

        foreach ($examples as $i => $ex) {
            echo "═════════════════════════════════════════════════════════════\n";
            echo "EJEMPLO " . ($i + 1) . ":\n";
            echo "═════════════════════════════════════════════════════════════\n";

            $data = (array)$ex;
            foreach ($data as $key => $value) {
                $val = $value ?? 'NULL';
                if (strlen($val) > 60) $val = substr($val, 0, 60) . '...';
                echo "  {$key}: {$val}\n";
            }
            echo "\n";
        }

        // Ejemplos para probar
        echo "╔════════════════════════════════════════════════════════════╗\n";
        echo "║           📋 EJEMPLOS PARA PROBAR EL FORMULARIO           ║\n";
        echo "╚════════════════════════════════════════════════════════════╝\n\n";

        foreach ($examples as $idx => $row) {
            echo "Ejemplo " . ($idx + 1) . ":\n";
            echo "  Cuenta (ID Multa): {$row->id_multa}\n";
            echo "  Folio (Acta): {$row->folio}\n";
            echo "  Contribuyente: {$row->contribuyente}\n";
            echo "  Calificación: \${$row->calificacion}\n";
            echo "  Tipo: {$row->tipo_calificacion}\n";
            echo "\n";
        }
    } else {
        echo "❌ No se encontraron ejemplos\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
