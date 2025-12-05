<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sol_sdos_favor...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sol_sdos_favor.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros)
    echo "Test 1: Sin filtro (últimas 5 solicitudes)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sol_sdos_favor('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: Folio {$r->folio}/{$r->axofol} - Cuenta {$r->cvecuenta}\n";
        echo "  Solicitante: " . trim($r->solicitante) . "\n";
    }
    echo "\n";

    // Test 2: Buscar por cuenta específica
    echo "Test 2: Buscar por cuenta '295685'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sol_sdos_favor('295685')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        foreach ($result as $r) {
            echo "  Resultado:\n";
            echo "    • ID Solicitud: {$r->id_solic}\n";
            echo "    • Folio: {$r->folio}/{$r->axofol}\n";
            echo "    • Cuenta: {$r->cvecuenta}\n";
            echo "    • Domicilio: " . trim($r->domp) . " " . trim($r->extp) . "\n";
            echo "    • Colonia: " . trim($r->colp) . "\n";
            echo "    • Solicitante: " . trim($r->solicitante) . "\n";
            echo "    • Status: " . trim($r->status) . "\n";
            echo "    • Fecha Captura: {$r->feccap}\n";
            echo "    • Capturista: " . trim($r->capturista) . "\n";
            echo "\n";
        }
    }

    // Test 3: Buscar por otra cuenta
    echo "Test 3: Buscar por cuenta '142963'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sol_sdos_favor('142963')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Folio: {$r->folio}/{$r->axofol}\n";
        echo "    • Cuenta: {$r->cvecuenta}\n";
        echo "    • Domicilio: " . trim($r->domp) . " " . trim($r->extp) . "\n";
        echo "    • Status: " . trim($r->status) . "\n";
    }
    echo "\n";

    // Test 4: Buscar por tercera cuenta
    echo "Test 4: Buscar por cuenta '103753'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sol_sdos_favor('103753')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Folio: {$r->folio}/{$r->axofol}\n";
        echo "    • Cuenta: {$r->cvecuenta}\n";
        echo "    • Domicilio: " . trim($r->domp) . " " . trim($r->extp) . "\n";
        echo "    • Status: " . trim($r->status) . "\n";
    }
    echo "\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 DESPLIEGUE EXITOSO 🎉                      ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 EJEMPLOS PARA PROBAR EN EL FRONTEND:\n\n";

    // Obtener 3 ejemplos concretos de las últimas solicitudes
    $ejemplos = DB::connection('pgsql')->select("
        SELECT *
        FROM catastro_gdl.solic_sdosfavor
        ORDER BY id_solic DESC
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '{$ej->cvecuenta}' (buscar por cuenta)\n";
        echo "  Resultado esperado:\n";
        echo "    • ID Solicitud: {$ej->id_solic}\n";
        echo "    • Folio: {$ej->folio}/{$ej->axofol}\n";
        echo "    • Cuenta: {$ej->cvecuenta}\n";
        echo "    • Domicilio: " . trim($ej->domp) . " " . trim($ej->extp) . "\n";
        echo "    • Colonia: " . trim($ej->colp) . "\n";
        echo "    • Solicitante: " . trim($ej->solicitante) . "\n";
        echo "    • Teléfono: " . ($ej->telefono ?? 'N/A') . "\n";
        echo "    • Status: " . trim($ej->status) . "\n";
        echo "    • Fecha Captura: {$ej->feccap}\n";
        echo "    • Capturista: " . trim($ej->capturista) . "\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra las últimas solicitudes\n";
    echo "  • '295685' → Busca por cuenta\n";
    echo "  • '1310' → Busca por folio\n";
    echo "  • '26176' → Busca por ID de solicitud\n";
    echo "\n";
    echo "📊 SISTEMA: Solicitudes de Saldos a Favor\n";
    echo "   • Total de registros en BD: 25,968\n";
    echo "   • Función: Gestionar solicitudes de devolución de saldos a favor\n";
    echo "   • Incluye: Folios, cuentas, domicilios, solicitantes, status\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
