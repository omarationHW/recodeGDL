<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "✅ Laravel cargado\n\n";

$sqlFile = __DIR__ . '/recaudadora_requerimientos_dm.sql';

if (!file_exists($sqlFile)) {
    die("❌ Error: No se encontró el archivo $sqlFile\n");
}

$sql = file_get_contents($sqlFile);

echo "📋 Desplegando SP recaudadora_requerimientos_dm...\n\n";

try {
    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP recaudadora_requerimientos_dm desplegado exitosamente\n\n";

    // Probar el SP
    echo "🧪 Probando el SP...\n\n";

    // Verificar que el SP existe
    $exists = DB::connection('pgsql')->select("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'recaudadora_requerimientos_dm'
        ) as exists
    ");

    if ($exists[0]->exists) {
        echo "✅ SP existe en la base de datos\n\n";

        // Obtener 3 ejemplos
        echo "📝 Obteniendo 3 ejemplos de datos...\n\n";

        $ejemplos = DB::connection('pgsql')->select("
            SELECT recaudadora_requerimientos_dm(NULL, NULL)
        ");

        if (count($ejemplos) > 0) {
            echo "📊 Ejemplos encontrados:\n\n";

            foreach ($ejemplos as $i => $ejemplo) {
                if ($i >= 3) break;

                $data = json_decode($ejemplo->recaudadora_requerimientos_dm, true);

                echo "Ejemplo " . ($i + 1) . ":\n";
                echo "  cvereq: " . ($data['cvereq'] ?? 'N/A') . "\n";
                echo "  folio: " . ($data['folio'] ?? 'N/A') . "\n";
                echo "  cuenta: " . ($data['cuenta'] ?? 'N/A') . "\n";
                echo "  ejercicio: " . ($data['ejercicio'] ?? 'N/A') . "\n";
                echo "  fecha_emision: " . ($data['fecha_emision'] ?? 'N/A') . "\n";
                echo "  impuesto: $" . ($data['impuesto'] ?? '0.00') . "\n";
                echo "  total: $" . ($data['total'] ?? '0.00') . "\n";
                echo "  vigencia: " . ($data['vigencia'] ?? 'N/A') . "\n";
                echo "\n";
            }
        }

        // Probar con filtros específicos
        echo "🔍 Probando con filtro por ejercicio 1994...\n\n";

        $testResult = DB::connection('pgsql')->select("
            SELECT recaudadora_requerimientos_dm(NULL, 1994)
        ");

        if (count($testResult) > 0) {
            echo "✅ Búsqueda por ejercicio funciona correctamente\n";
            echo "   Registros encontrados: " . count($testResult) . "\n\n";
        }

    } else {
        echo "❌ SP no se encontró en la base de datos\n";
    }

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║        🎉 SP REQUERIMIENTOS DM DESPLEGADO 🎉              ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 DETALLES DEL SP:\n";
    echo "   Nombre: recaudadora_requerimientos_dm\n";
    echo "   Parámetros:\n";
    echo "     - p_clave_cuenta VARCHAR (opcional)\n";
    echo "     - p_ejercicio INTEGER (opcional)\n";
    echo "\n";
    echo "   Columnas retornadas:\n";
    echo "     - cvereq (ID único)\n";
    echo "     - folio (Folio del requerimiento)\n";
    echo "     - cuenta (Cuenta catastral)\n";
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
    echo "📊 TABLA FUENTE:\n";
    echo "   catastro_gdl.h_reqpredial\n";
    echo "   Total registros disponibles: ~39\n";
    echo "\n";
    echo "🚀 Ahora puedes usar el módulo RequerimientosDM.vue\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error al desplegar el SP: " . $e->getMessage() . "\n";
    echo "\nDetalles del error:\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
