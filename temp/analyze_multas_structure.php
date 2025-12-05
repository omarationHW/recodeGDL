<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Analizando tabla de multas...\n\n";

try {
    // Obtener estructura de la tabla multas
    $cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'multas'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    echo "📋 ESTRUCTURA DE catastro_gdl.multas:\n\n";
    foreach ($cols as $col) {
        echo "  • {$col->column_name} ({$col->data_type})\n";
    }

    // Buscar ejemplos con los IDs que tenemos
    echo "\n═══════════════════════════════════════════════════════════\n";
    echo "📊 EJEMPLOS DE MULTAS CON CALIFICACIÓN:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $testIds = [415267, 415189, 415266];

    foreach ($testIds as $idx => $idMulta) {
        $multa = DB::connection('pgsql')->selectOne("
            SELECT *
            FROM catastro_gdl.multas
            WHERE cvemul = ?
        ", [$idMulta]);

        if ($multa) {
            echo "MULTA {$idMulta}:\n";
            $data = (array)$multa;
            $important = ['cvemul', 'folmul', 'cvecuenta', 'impfijo', 'importe', 'total', 'fecalta', 'axomul'];
            foreach ($important as $key) {
                if (isset($data[$key])) {
                    $val = $data[$key] ?? 'NULL';
                    echo "  {$key}: {$val}\n";
                }
            }
            echo "\n";
        }
    }

    // Crear query completa de ejemplo
    echo "═══════════════════════════════════════════════════════════\n";
    echo "🔍 JOIN COMPLETO CON CALIFICACIONES:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $joined = DB::connection('pgsql')->select("
        SELECT
            m.cvemul,
            m.folmul,
            m.cvecuenta,
            m.importe,
            m.fecalta,
            tc.tipo_calificacion,
            tc.usuario as usuario_calificacion,
            tc.fecha_actual as fecha_calificacion
        FROM catastro_gdl.multas m
        INNER JOIN catastro_gdl.tipo_calificacion_multa tc ON tc.id_multa = m.cvemul
        WHERE m.cvemul IN (415267, 415189, 415266)
        ORDER BY m.cvemul DESC
    ");

    foreach ($joined as $row) {
        echo "Multa {$row->cvemul}:\n";
        echo "  Folio: {$row->folmul}\n";
        echo "  Cuenta: {$row->cvecuenta}\n";
        echo "  Importe: \${$row->importe}\n";
        echo "  Tipo Calificación: {$row->tipo_calificacion}\n";
        echo "  Usuario: {$row->usuario_calificacion}\n";
        echo "  Fecha: {$row->fecha_calificacion}\n";
        echo "\n";
    }

    // Obtener cuentas y folios para ejemplos
    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║           📋 EJEMPLOS PARA PROBAR                          ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n\n";

    foreach ($joined as $idx => $row) {
        echo "Ejemplo " . ($idx + 1) . ":\n";
        echo "  Cuenta: {$row->cvecuenta}\n";
        echo "  Folio: {$row->folmul}\n";
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
