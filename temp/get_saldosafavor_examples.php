<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Obteniendo ejemplos de catastro_gdl.saldosafavor...\n\n";

try {
    // Obtener 3 ejemplos de la tabla principal
    $samples = DB::connection('pgsql')->select("
        SELECT *
        FROM catastro_gdl.saldosafavor
        WHERE cvecuenta IS NOT NULL
        ORDER BY cvecuenta DESC
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
                if (strlen($val) > 60) $val = substr($val, 0, 60) . '...';
                echo "  {$key}: {$val}\n";
            }
            echo "\n";
        }

        // Extraer cuentas para ejemplos
        echo "╔════════════════════════════════════════════════════════════╗\n";
        echo "║           📋 EJEMPLOS PARA PROBAR EL FORMULARIO           ║\n";
        echo "╚════════════════════════════════════════════════════════════╝\n\n";

        foreach ($samples as $i => $sample) {
            if ($i >= 3) break;

            echo "Ejemplo " . ($i + 1) . ":\n";
            echo "  Cuenta: {$sample->cvecuenta}\n";
            echo "  Folio: {$sample->folio}\n";
            echo "  Saldo Inicial: $" . number_format($sample->saldoinicial, 2) . "\n";
            echo "  Importe Aplicado: $" . number_format($sample->importeaplicado, 2) . "\n";
            $saldoRestante = $sample->saldoinicial - $sample->importeaplicado;
            echo "  Saldo Restante: $" . number_format($saldoRestante, 2) . "\n";
            echo "  Fecha Alta: {$sample->fechaalta}\n";
            echo "\n";
        }

        // Estadísticas
        echo "═══════════════════════════════════════════════════════════\n";
        echo "📊 ESTADÍSTICAS:\n";
        echo "═══════════════════════════════════════════════════════════\n\n";

        $stats = DB::connection('pgsql')->selectOne("
            SELECT
                COUNT(*) as total,
                COUNT(DISTINCT cvecuenta) as cuentas_unicas,
                SUM(saldoinicial) as total_saldo_inicial,
                SUM(importeaplicado) as total_aplicado,
                SUM(saldoinicial - importeaplicado) as total_saldo_restante
            FROM catastro_gdl.saldosafavor
        ");

        echo "Total registros: {$stats->total}\n";
        echo "Cuentas únicas: {$stats->cuentas_unicas}\n";
        echo "Total Saldo Inicial: $" . number_format($stats->total_saldo_inicial, 2) . "\n";
        echo "Total Aplicado: $" . number_format($stats->total_aplicado, 2) . "\n";
        echo "Total Saldo Restante: $" . number_format($stats->total_saldo_restante, 2) . "\n";

    } else {
        echo "❌ No se encontraron datos\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
