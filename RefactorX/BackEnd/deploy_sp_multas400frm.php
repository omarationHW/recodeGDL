<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_multas400frm ===\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multas400frm.sql';

    if (!file_exists($sqlFile)) {
        echo "❌ Error: No se encontró el archivo SQL\n";
        exit(1);
    }

    $sql = file_get_contents($sqlFile);

    echo "📄 Desplegando SP desde: recaudadora_multas400frm.sql\n";
    echo str_repeat("=", 80) . "\n\n";

    // Ejecutar el SQL
    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar que existe
    echo "Verificando existencia del SP...\n";
    $exists = DB::connection('pgsql')->selectOne("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'multas_reglamentos'
            AND p.proname = 'recaudadora_multas400frm'
        ) as exists
    ");

    if ($exists->exists) {
        echo "✅ SP verificado en base de datos\n\n";
    } else {
        echo "❌ Error: SP no encontrado después del despliegue\n";
        exit(1);
    }

    // EJEMPLO 1: Buscar por ID de multa
    echo str_repeat("=", 80) . "\n";
    echo "EJEMPLO 1: Buscar por ID de multa '406'\n";
    echo str_repeat("=", 80) . "\n\n";

    $ejemplo1 = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_multas400frm('406')
        LIMIT 3
    ");

    if (count($ejemplo1) > 0) {
        foreach ($ejemplo1 as $i => $row) {
            $num = $i + 1;
            echo "$num. ID Multa: {$row->id_multa}\n";
            echo "   Acta: {$row->num_acta}/{$row->axo_acta}\n";
            echo "   Fecha: {$row->fecha_acta}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Domicilio: {$row->domicilio}\n";
            echo "   Multa: $" . number_format($row->multa, 2) . "\n";
            echo "   Gastos: $" . number_format($row->gastos, 2) . "\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "   Dependencia: {$row->id_dependencia}\n";
            echo "   Expediente: {$row->expediente}\n";
            echo "   CVE Pago: " . ($row->cvepago ?: 'SIN PAGO') . "\n";
            echo "   Observación: {$row->observacion}\n\n";
        }
    } else {
        echo "No se encontraron resultados\n\n";
    }

    // EJEMPLO 2: Buscar por número de acta
    echo str_repeat("=", 80) . "\n";
    echo "EJEMPLO 2: Buscar por número de acta '97'\n";
    echo str_repeat("=", 80) . "\n\n";

    $ejemplo2 = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_multas400frm('97')
        LIMIT 3
    ");

    if (count($ejemplo2) > 0) {
        foreach ($ejemplo2 as $i => $row) {
            $num = $i + 1;
            echo "$num. ID Multa: {$row->id_multa}\n";
            echo "   Acta: {$row->num_acta}/{$row->axo_acta}\n";
            echo "   Fecha: {$row->fecha_acta}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Domicilio: {$row->domicilio}\n";
            echo "   Multa: $" . number_format($row->multa, 2) . "\n";
            echo "   Gastos: $" . number_format($row->gastos, 2) . "\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n\n";
        }
    } else {
        echo "No se encontraron resultados\n\n";
    }

    // EJEMPLO 3: Buscar por nombre de contribuyente
    echo str_repeat("=", 80) . "\n";
    echo "EJEMPLO 3: Buscar por contribuyente 'GOMEZ'\n";
    echo str_repeat("=", 80) . "\n\n";

    $ejemplo3 = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_multas400frm('GOMEZ')
        LIMIT 3
    ");

    if (count($ejemplo3) > 0) {
        foreach ($ejemplo3 as $i => $row) {
            $num = $i + 1;
            echo "$num. ID Multa: {$row->id_multa}\n";
            echo "   Acta: {$row->num_acta}/{$row->axo_acta}\n";
            echo "   Fecha: {$row->fecha_acta}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Domicilio: {$row->domicilio}\n";
            echo "   Multa: $" . number_format($row->multa, 2) . "\n";
            echo "   Gastos: $" . number_format($row->gastos, 2) . "\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n\n";
        }
    } else {
        echo "No se encontraron resultados\n\n";
    }

    echo str_repeat("=", 80) . "\n";
    echo "✅ DESPLIEGUE Y PRUEBAS COMPLETADOS\n";
    echo str_repeat("=", 80) . "\n\n";

    echo "TABLA DE ORIGEN: comun.multas (415,017 registros)\n";
    echo "PARÁMETRO: p_filtro (VARCHAR) - Busca en ID, acta, contribuyente, expediente\n";
    echo "LÍMITE: 100 registros por consulta\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
