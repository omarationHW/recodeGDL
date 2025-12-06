<?php
/**
 * DEPLOYMENT - SP sp_reporte_adeudos_condonados
 *
 * Despliega el stored procedure para el componente RepAdeudCond.vue
 * Base: padron_licencias
 *
 * Fecha: 2025-12-05
 */

// Configuración de Laravel
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "\n";
echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ DEPLOYMENT - SP sp_reporte_adeudos_condonados                               ║\n";
echo "║ Componente: RepAdeudCond.vue                                                 ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n";
echo "\n";

$spFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RepAdeudCond_sp_reporte_adeudos_condonados.sql';

if (!file_exists($spFile)) {
    echo "❌ ERROR: No se encontró el archivo SQL:\n";
    echo "   $spFile\n";
    exit(1);
}

$sql = file_get_contents($spFile);

try {
    echo "📦 Desplegando sp_reporte_adeudos_condonados...\n";

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ sp_reporte_adeudos_condonados desplegado exitosamente\n";

    // Verificar que el SP existe
    $check = DB::connection('pgsql')->select("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_type = 'FUNCTION'
        AND routine_name = 'sp_reporte_adeudos_condonados'
        AND routine_schema = 'public'
    ");

    if (count($check) > 0) {
        echo "✅ Verificación: SP encontrado en schema public\n";
    } else {
        echo "⚠️  Advertencia: No se pudo verificar el SP en la base de datos\n";
    }

    echo "\n";
    echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
    echo "║ ✅ DESPLIEGUE COMPLETADO EXITOSAMENTE                                        ║\n";
    echo "╚══════════════════════════════════════════════════════════════════════════════╝\n";
    echo "\n";

    echo "El SP está listo para ser usado por:\n";
    echo "  - Componente: RepAdeudCond.vue\n";
    echo "  - Base de datos: padron_licencias (conexión pgsql)\n";
    echo "  - Parámetros: p_oficina, p_axo, p_periodo, p_mercado (opcional)\n";
    echo "\n";

} catch (Exception $e) {
    echo "\n";
    echo "❌ ERROR al desplegar el SP:\n";
    echo "   " . $e->getMessage() . "\n";
    echo "\n";
    exit(1);
}
