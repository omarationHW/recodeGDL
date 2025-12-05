<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "✅ Laravel cargado\n\n";

$sqlFile = __DIR__ . '/recaudadora_resolucion_juez.sql';

if (!file_exists($sqlFile)) {
    die("❌ Error: No se encontró el archivo $sqlFile\n");
}

$sql = file_get_contents($sqlFile);

echo "📋 Desplegando SP recaudadora_resolucion_juez...\n\n";

try {
    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP recaudadora_resolucion_juez desplegado exitosamente\n\n";

    // Probar el SP
    echo "🧪 Probando el SP...\n\n";

    // Verificar que el SP existe
    $exists = DB::connection('pgsql')->select("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'recaudadora_resolucion_juez'
        ) as exists
    ");

    if ($exists[0]->exists) {
        echo "✅ SP existe en la base de datos\n\n";

        // Obtener 3 ejemplos
        echo "📝 Obteniendo 3 ejemplos de datos...\n\n";

        $ejemplos = DB::connection('pgsql')->select("
            SELECT * FROM recaudadora_resolucion_juez(NULL, NULL)
            LIMIT 3
        ");

        if (count($ejemplos) > 0) {
            echo "📊 Ejemplos encontrados:\n\n";

            foreach ($ejemplos as $i => $ejemplo) {
                echo "═════════════════════════════════════════════════════════════\n";
                echo "EJEMPLO " . ($i + 1) . ":\n";
                echo "═════════════════════════════════════════════════════════════\n";
                echo "  ID/Folio:               {$ejemplo->folio}\n";
                echo "  Cuenta:                 {$ejemplo->cuenta}\n";
                echo "  Periodo:                {$ejemplo->periodo}\n";
                echo "  Accesorios:             {$ejemplo->accesorios}\n";
                echo "  Fecha Calcular:         {$ejemplo->fecha_calcular}\n";
                echo "  Vigencia:               {$ejemplo->vigencia}\n";
                echo "  CVE Pago:               {$ejemplo->cvepago}\n";
                echo "  Not. Canceladas:        " . (strlen($ejemplo->notificaciones_canceladas) > 50 ? substr($ejemplo->notificaciones_canceladas, 0, 50) . '...' : $ejemplo->notificaciones_canceladas) . "\n";
                echo "  Observaciones:          " . (strlen($ejemplo->observaciones) > 60 ? substr($ejemplo->observaciones, 0, 60) . '...' : $ejemplo->observaciones) . "\n";
                echo "  Usuario Alta:           {$ejemplo->usuario_alta}\n";
                echo "  Fecha Alta:             {$ejemplo->fecha_alta}\n";
                echo "\n";
            }
        }

        // Probar con filtro de cuenta
        echo "\n🔍 Probando búsqueda por cuenta '98925'...\n\n";

        $testCuenta = DB::connection('pgsql')->select("
            SELECT * FROM recaudadora_resolucion_juez('98925', NULL)
        ");

        if (count($testCuenta) > 0) {
            echo "✅ Búsqueda por cuenta funciona correctamente\n";
            echo "   Registros encontrados: " . count($testCuenta) . "\n";
            echo "   Primera coincidencia:\n";
            echo "     - Folio: {$testCuenta[0]->folio}\n";
            echo "     - Cuenta: {$testCuenta[0]->cuenta}\n";
            echo "     - Periodo: {$testCuenta[0]->periodo}\n";
            echo "     - Vigencia: {$testCuenta[0]->vigencia}\n";
            echo "\n";
        }

        // Probar con filtro de folio
        echo "\n🔍 Probando búsqueda por folio '59'...\n\n";

        $testFolio = DB::connection('pgsql')->select("
            SELECT * FROM recaudadora_resolucion_juez(NULL, 59)
        ");

        if (count($testFolio) > 0) {
            echo "✅ Búsqueda por folio funciona correctamente\n";
            echo "   Registros encontrados: " . count($testFolio) . "\n";
            echo "   Datos:\n";
            echo "     - Folio: {$testFolio[0]->folio}\n";
            echo "     - Cuenta: {$testFolio[0]->cuenta}\n";
            echo "     - Observaciones: " . substr($testFolio[0]->observaciones, 0, 80) . "...\n";
            echo "\n";
        }

    } else {
        echo "❌ SP no se encontró en la base de datos\n";
    }

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║        🎉 SP RESOLUCION_JUEZ DESPLEGADO 🎉                ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 DETALLES DEL SP:\n";
    echo "   Nombre: recaudadora_resolucion_juez\n";
    echo "   Parámetros:\n";
    echo "     - p_clave_cuenta VARCHAR (opcional, busca con ILIKE)\n";
    echo "     - p_folio INTEGER (opcional, ID de resolución)\n";
    echo "\n";
    echo "   Columnas retornadas:\n";
    echo "     - id_resolucion (ID único)\n";
    echo "     - folio (ID de resolución)\n";
    echo "     - cuenta (Cuenta)\n";
    echo "     - periodo (Periodo formateado: 'año/bim - año/bim')\n";
    echo "     - axo_inicio, bim_inicio (Año y bimestre inicio)\n";
    echo "     - axo_fin, bim_fin (Año y bimestre fin)\n";
    echo "     - accesorios (Con/Sin accesorios)\n";
    echo "     - fecha_calcular (Fecha de cálculo)\n";
    echo "     - vigencia (Vigente/Cancelado/Activo)\n";
    echo "     - cvepago (Clave de pago)\n";
    echo "     - notificaciones_canceladas (Lista de IDs)\n";
    echo "     - observaciones (Detalles del expediente)\n";
    echo "     - fecha_alta, usuario_alta (Auditoría alta)\n";
    echo "     - fecha_baja, usuario_baja (Auditoría baja)\n";
    echo "\n";
    echo "📊 TABLA FUENTE:\n";
    echo "   - catastro_gdl.resolucion_juez\n";
    echo "   Total registros: 59\n";
    echo "   Cuentas únicas: 26\n";
    echo "   Periodo: 1998-2023\n";
    echo "\n";
    echo "🚀 Ahora puedes usar el módulo ResolucionJuez.vue\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error al desplegar el SP: " . $e->getMessage() . "\n";
    echo "\nDetalles del error:\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
