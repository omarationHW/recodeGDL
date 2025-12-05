<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📝 Obteniendo ejemplos reales de datos para RequerimientosDM...\n\n";

try {
    // Obtener 3 ejemplos reales
    $ejemplos = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_requerimientos_dm(NULL, NULL)
        LIMIT 3
    ");

    echo "📊 EJEMPLOS DE DATOS REALES:\n\n";

    foreach ($ejemplos as $i => $ej) {
        echo "═════════════════════════════════════════════════════════════\n";
        echo "EJEMPLO " . ($i + 1) . ":\n";
        echo "═════════════════════════════════════════════════════════════\n";
        echo "  ID (cvereq):       {$ej->cvereq}\n";
        echo "  Folio:             {$ej->folio}\n";
        echo "  Cuenta:            {$ej->cuenta}\n";
        echo "  Ejercicio (año):   {$ej->ejercicio}\n";
        echo "  Fecha emisión:     {$ej->fecha_emision}\n";
        echo "  Fecha entrega:     {$ej->fecha_entrega}\n";
        echo "  Impuesto:          \${$ej->impuesto}\n";
        echo "  Recargos:          \${$ej->recargos}\n";
        echo "  Gastos:            \${$ej->gastos}\n";
        echo "  Multas:            \${$ej->multas}\n";
        echo "  Total:             \${$ej->total}\n";
        echo "  Vigencia:          {$ej->vigencia}\n";
        echo "\n";
    }

    echo "\n╔════════════════════════════════════════════════════════════╗\n";
    echo "║               📋 EJEMPLOS PARA PROBAR                      ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n\n";

    if (count($ejemplos) > 0) {
        echo "FILTROS SUGERIDOS PARA PROBAR:\n\n";

        foreach ($ejemplos as $i => $ej) {
            echo "Ejemplo " . ($i + 1) . ":\n";
            echo "  - Buscar por cuenta: {$ej->cuenta}\n";
            echo "  - Buscar por ejercicio: {$ej->ejercicio}\n";
            echo "\n";
        }
    }

    // Obtener estadísticas
    echo "\n📊 ESTADÍSTICAS GENERALES:\n\n";

    $total = DB::connection('pgsql')->selectOne("
        SELECT COUNT(*) as total FROM catastro_gdl.h_reqpredial
    ");
    echo "  Total de requerimientos: {$total->total}\n";

    $porVigencia = DB::connection('pgsql')->select("
        SELECT
            CASE
                WHEN vigencia = 'P' THEN 'Pendiente'
                WHEN vigencia = 'C' THEN 'Cancelado'
                WHEN vigencia = 'E' THEN 'Entregado'
                ELSE 'Otro'
            END as estatus,
            COUNT(*) as cantidad
        FROM catastro_gdl.h_reqpredial
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "  Por estatus:\n";
    foreach ($porVigencia as $stat) {
        echo "    - {$stat->estatus}: {$stat->cantidad}\n";
    }

    $ejercicios = DB::connection('pgsql')->select("
        SELECT axoreq as ejercicio, COUNT(*) as cantidad
        FROM catastro_gdl.h_reqpredial
        GROUP BY axoreq
        ORDER BY axoreq DESC
        LIMIT 5
    ");

    echo "  Ejercicios con más requerimientos:\n";
    foreach ($ejercicios as $ej) {
        echo "    - Año {$ej->ejercicio}: {$ej->cantidad} requerimientos\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
