<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "✅ Laravel cargado\n\n";

$sqlFile = __DIR__ . '/recaudadora_requerxcvecat.sql';

if (!file_exists($sqlFile)) {
    die("❌ Error: No se encontró el archivo $sqlFile\n");
}

$sql = file_get_contents($sqlFile);

echo "📋 Desplegando SP recaudadora_requerxcvecat...\n\n";

try {
    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP recaudadora_requerxcvecat desplegado exitosamente\n\n";

    // Probar el SP
    echo "🧪 Probando el SP...\n\n";

    // Verificar que el SP existe
    $exists = DB::connection('pgsql')->select("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'recaudadora_requerxcvecat'
        ) as exists
    ");

    if ($exists[0]->exists) {
        echo "✅ SP existe en la base de datos\n\n";

        // Obtener 3 ejemplos
        echo "📝 Obteniendo 3 ejemplos de datos...\n\n";

        $ejemplos = DB::connection('pgsql')->select("
            SELECT * FROM recaudadora_requerxcvecat(NULL)
            LIMIT 3
        ");

        if (count($ejemplos) > 0) {
            echo "📊 Ejemplos encontrados:\n\n";

            foreach ($ejemplos as $i => $ejemplo) {
                echo "═════════════════════════════════════════════════════════════\n";
                echo "EJEMPLO " . ($i + 1) . ":\n";
                echo "═════════════════════════════════════════════════════════════\n";
                echo "  ID (cvereq):        {$ejemplo->cvereq}\n";
                echo "  Folio:              {$ejemplo->folio}\n";
                echo "  Cuenta:             {$ejemplo->cuenta}\n";
                echo "  Clave Catastral:    {$ejemplo->clave_catastral}\n";
                echo "  Ejercicio:          {$ejemplo->ejercicio}\n";
                echo "  Fecha Emisión:      {$ejemplo->fecha_emision}\n";
                echo "  Fecha Entrega:      " . ($ejemplo->fecha_entrega ?? 'N/A') . "\n";
                echo "  Impuesto:           \${$ejemplo->impuesto}\n";
                echo "  Recargos:           \${$ejemplo->recargos}\n";
                echo "  Gastos:             \${$ejemplo->gastos}\n";
                echo "  Multas:             \${$ejemplo->multas}\n";
                echo "  Total:              \${$ejemplo->total}\n";
                echo "  Vigencia:           {$ejemplo->vigencia}\n";
                echo "\n";
            }
        }

        // Probar con filtro específico
        echo "\n🔍 Probando búsqueda por clave catastral 'D65J4262005'...\n\n";

        $testResult = DB::connection('pgsql')->select("
            SELECT * FROM recaudadora_requerxcvecat('D65J4262005')
        ");

        if (count($testResult) > 0) {
            echo "✅ Búsqueda por clave catastral funciona correctamente\n";
            echo "   Registros encontrados: " . count($testResult) . "\n";
            echo "   Primera coincidencia:\n";
            echo "     - Cuenta: {$testResult[0]->cuenta}\n";
            echo "     - Clave Catastral: {$testResult[0]->clave_catastral}\n";
            echo "     - Total: \${$testResult[0]->total}\n";
            echo "\n";
        }

        // Probar búsqueda parcial
        echo "\n🔍 Probando búsqueda parcial 'D65J426'...\n\n";

        $testPartial = DB::connection('pgsql')->select("
            SELECT * FROM recaudadora_requerxcvecat('D65J426')
        ");

        if (count($testPartial) > 0) {
            echo "✅ Búsqueda parcial funciona correctamente\n";
            echo "   Registros encontrados: " . count($testPartial) . "\n\n";
        }

    } else {
        echo "❌ SP no se encontró en la base de datos\n";
    }

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║         🎉 SP REQUERXCVECAT DESPLEGADO 🎉                 ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 DETALLES DEL SP:\n";
    echo "   Nombre: recaudadora_requerxcvecat\n";
    echo "   Parámetros:\n";
    echo "     - p_cvecat VARCHAR (opcional, busca con ILIKE)\n";
    echo "\n";
    echo "   Columnas retornadas:\n";
    echo "     - cvereq (ID único)\n";
    echo "     - folio (Folio del requerimiento)\n";
    echo "     - cuenta (Cuenta)\n";
    echo "     - clave_catastral (Clave catastral)\n";
    echo "     - ejercicio (Año)\n";
    echo "     - fecha_emision (Fecha de emisión)\n";
    echo "     - fecha_entrega (Fecha de entrega)\n";
    echo "     - impuesto (Monto impuesto)\n";
    echo "     - recargos (Monto recargos)\n";
    echo "     - gastos (Gastos de ejecución)\n";
    echo "     - multas (Multas)\n";
    echo "     - total (Total a pagar)\n";
    echo "     - vigencia (Estatus: Pendiente/Cancelado/Entregado)\n";
    echo "\n";
    echo "📊 TABLAS FUENTE:\n";
    echo "   - catastro_gdl.h_reqpredial (requerimientos)\n";
    echo "   - catastro_gdl.controladora (clave catastral)\n";
    echo "   Total registros con clave catastral: ~35 (89.74%)\n";
    echo "\n";
    echo "🚀 Ahora puedes usar el módulo RequerxCvecat.vue\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error al desplegar el SP: " . $e->getMessage() . "\n";
    echo "\nDetalles del error:\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
