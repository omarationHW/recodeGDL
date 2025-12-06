<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_trasladosfrm...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_trasladosfrm.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros)
    echo "Test 1: Sin filtro (últimos 5 traslados)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_trasladosfrm('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: Ejercicio {$r->ejercicio} - Dependencia {$r->dependencia} - Partida {$r->partida}\n";
    }
    echo "\n";

    // Test 2: Buscar por ejercicio 2004
    echo "Test 2: Buscar por ejercicio '2004'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_trasladosfrm('2004')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        foreach ($result as $i => $r) {
            if ($i >= 3) break;
            echo "  Resultado " . ($i + 1) . ":\n";
            echo "    • Ejercicio: {$r->ejercicio}\n";
            echo "    • Dependencia: {$r->dependencia}\n";
            echo "    • Partida: {$r->partida}\n";
            echo "    • Presupuesto Anual: $" . number_format($r->presup_anual, 2) . "\n";
            echo "    • Trans. Aumento: $" . number_format($r->trans_aumento, 2) . "\n";
            echo "    • Trans. Disminución: $" . number_format($r->trans_disminucion, 2) . "\n";
            echo "\n";
        }
    }

    // Test 3: Buscar por dependencia 1000
    echo "Test 3: Buscar por dependencia '1000'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_trasladosfrm('1000')
        LIMIT 3
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Ejercicio: {$r->ejercicio}\n";
        echo "    • Dependencia: {$r->dependencia}\n";
        echo "    • Partida: {$r->partida}\n";
        echo "    • Presupuesto Anual: $" . number_format($r->presup_anual, 2) . "\n";
    }
    echo "\n";

    // Test 4: Buscar por dependencia 2000
    echo "Test 4: Buscar por dependencia '2000'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_trasladosfrm('2000')
        LIMIT 3
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Dependencia: {$r->dependencia}\n";
        echo "    • Presupuesto: $" . number_format($r->presup_anual, 2) . "\n";
    }
    echo "\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 DESPLIEGUE EXITOSO 🎉                      ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 EJEMPLOS PARA PROBAR EN EL FRONTEND:\n\n";

    // Obtener 3 ejemplos concretos
    $ejemplos = DB::connection('pgsql')->select("
        SELECT *
        FROM comun.ta_transfer
        ORDER BY ejercicio DESC, dependencia, partida
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '{$ej->ejercicio}' (buscar por ejercicio)\n";
        echo "  O: '{$ej->dependencia}' (buscar por dependencia)\n";
        echo "  Resultado esperado:\n";
        echo "    • Ejercicio: {$ej->ejercicio}\n";
        echo "    • Dependencia: {$ej->dependencia}\n";
        echo "    • Partida: {$ej->partida}\n";
        echo "    • Presupuesto Anual: $" . number_format($ej->presup_anual, 2) . "\n";
        echo "    • Aplicación Auto: $" . number_format($ej->apliacion_auto, 2) . "\n";
        echo "    • Trans. Aumento: $" . number_format($ej->trans_aumento, 2) . "\n";
        echo "    • Trans. Disminución: $" . number_format($ej->trans_disminucion, 2) . "\n";
        echo "    • Ampliación Nueva: $" . number_format($ej->ampliacion_nva, 2) . "\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra todos los traslados\n";
    echo "  • '2004' → Busca traslados del ejercicio 2004\n";
    echo "  • '1000' → Busca traslados de la dependencia 1000\n";
    echo "  • '100' → Busca traslados de la partida 100\n";
    echo "\n";
    echo "📊 SISTEMA: Traslados Presupuestarios\n";
    echo "   • Total de registros en BD: 6,579\n";
    echo "   • Función: Gestionar transferencias presupuestarias entre partidas\n";
    echo "   • Incluye: Aumentos, disminuciones y ampliaciones\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
