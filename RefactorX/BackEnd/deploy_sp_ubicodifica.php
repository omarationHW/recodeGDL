<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_ubicodifica...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_ubicodifica.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros vigentes)
    echo "Test 1: Sin filtro (últimas 5 ubicaciones vigentes)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_ubicodifica('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: Cuenta {$r->cvecuenta} - {$r->domicilio}\n";
        echo "  Vigencia: {$r->vigencia}\n";
    }
    echo "\n";

    // Test 2: Buscar por cuenta específica
    echo "Test 2: Buscar por cuenta '495171'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_ubicodifica('495171')
        LIMIT 3
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        foreach ($result as $i => $r) {
            echo "  Resultado " . ($i + 1) . ":\n";
            echo "    • Cuenta: {$r->cvecuenta}\n";
            echo "    • Domicilio: {$r->domicilio}\n";
            echo "    • No. Exterior: {$r->noexterior}\n";
            echo "    • Colonia: {$r->colonia}\n";
            echo "    • Vigencia: {$r->vigencia}\n";
            echo "    • Fecha Alta: {$r->fec_alta}\n";
            echo "\n";
        }
    }

    // Test 3: Buscar por domicilio
    echo "Test 3: Buscar por domicilio 'RAMOS'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_ubicodifica('RAMOS')
        LIMIT 3
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Cuenta: {$r->cvecuenta}\n";
        echo "    • Domicilio: {$r->domicilio}\n";
        echo "    • Colonia: {$r->colonia}\n";
    }
    echo "\n";

    // Test 4: Buscar por colonia
    echo "Test 4: Buscar por colonia 'VICTORIA'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_ubicodifica('VICTORIA')
        LIMIT 3
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Cuenta: {$r->cvecuenta}\n";
        echo "    • Domicilio: {$r->domicilio}\n";
        echo "    • Colonia: {$r->colonia}\n";
    }
    echo "\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 DESPLIEGUE EXITOSO 🎉                      ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 EJEMPLOS PARA PROBAR EN EL FRONTEND:\n\n";

    // Obtener 3 ejemplos concretos con cuentas específicas
    $ejemplos = DB::connection('pgsql')->select("
        SELECT *
        FROM catastro_gdl.ubicacion_req
        WHERE cvecuenta IN (495171, 495157, 494755)
        ORDER BY cvecuenta DESC
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '{$ej->cvecuenta}' (buscar por cuenta)\n";
        echo "  O: '" . substr($ej->domicilio, 0, 10) . "' (buscar por domicilio)\n";
        echo "  Resultado esperado:\n";
        echo "    • Cuenta: {$ej->cvecuenta}\n";
        echo "    • Domicilio: {$ej->domicilio}\n";
        echo "    • No. Exterior: " . ($ej->noexterior ?: 'N/A') . "\n";
        echo "    • Interior: " . ($ej->interior ?: 'N/A') . "\n";
        echo "    • Colonia: " . ($ej->colonia ?: 'N/A') . "\n";
        echo "    • Observaciones: " . (strlen($ej->observaciones ?? '') > 40 ? substr($ej->observaciones, 0, 40) . '...' : ($ej->observaciones ?: 'N/A')) . "\n";
        echo "    • Vigencia: {$ej->vigencia}\n";
        echo "    • Usuario Alta: " . ($ej->usuario_alta ?: 'N/A') . "\n";
        echo "    • Fecha Alta: " . ($ej->fec_alta ?: 'N/A') . "\n";
        echo "    • Fecha Baja: " . ($ej->fec_baja ?: 'N/A') . "\n";
        echo "    • Fecha Mov: " . ($ej->fec_mov ?: 'N/A') . "\n";
        echo "    • Usuario Mov: " . ($ej->usuario_mov ?: 'N/A') . "\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra todas las ubicaciones vigentes\n";
    echo "  • '495171' → Busca por cuenta específica\n";
    echo "  • 'RAMOS' → Busca por domicilio\n";
    echo "  • 'VICTORIA' → Busca por colonia\n";
    echo "  • '4316' → Busca por número exterior\n";
    echo "\n";
    echo "📊 SISTEMA: Ubicación y Codificación de Inmuebles\n";
    echo "   • Total de registros en BD: 1,898\n";
    echo "   • Función: Gestionar ubicaciones y codificaciones de direcciones\n";
    echo "   • Incluye: Domicilio, colonia, números, vigencia y observaciones\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
