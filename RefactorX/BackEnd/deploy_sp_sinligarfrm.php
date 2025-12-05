<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sinligarfrm...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sinligarfrm.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros)
    echo "Test 1: Sin filtro (últimos 5 registros)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sinligarfrm('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: ID {$r->id_control} - Pago {$r->cvepago} - Cuenta {$r->cvecta}\n";
    }
    echo "\n";

    // Test 2: Buscar por clave de pago
    echo "Test 2: Buscar por clave de pago '8118690'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sinligarfrm('8118690')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado: ID Control {$r->id_control}\n";
        echo "  Clave Pago: {$r->cvepago}\n";
        echo "  Clave Cuenta: {$r->cvecta}\n";
        echo "  Usuario: {$r->usuario}\n";
        echo "  Fecha: {$r->fecha_act}\n";
    }
    echo "\n";

    // Test 3: Buscar por usuario
    echo "Test 3: Buscar por usuario 'torozco'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sinligarfrm('torozco')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "  Primeros resultados:\n";
        foreach ($result as $i => $r) {
            if ($i >= 3) break;
            echo "    • ID {$r->id_control} - Pago {$r->cvepago} - Cuenta {$r->cvecta}\n";
        }
    }
    echo "\n";

    // Test 4: Buscar por tipo
    echo "Test 4: Buscar por tipo '22'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sinligarfrm('22')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: Tipo {$r->tipo} - Usuario {$r->usuario}\n";
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
        FROM comun.qligapago
        ORDER BY id_control DESC
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '{$ej->cvepago}' (buscar por clave de pago)\n";
        echo "  Resultado esperado:\n";
        echo "    • ID Control: {$ej->id_control}\n";
        echo "    • Clave Pago: {$ej->cvepago}\n";
        echo "    • Clave Cuenta: {$ej->cvecta}\n";
        echo "    • Usuario: " . trim($ej->usuario) . "\n";
        echo "    • Fecha: {$ej->fecha_act}\n";
        echo "    • Tipo: {$ej->tipo}\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra todos los registros\n";
    echo "  • '465632' → Busca por clave de cuenta\n";
    echo "  • 'torozco' → Busca por usuario\n";
    echo "  • '22' → Busca por tipo de ligadura\n";
    echo "\n";
    echo "📊 SISTEMA: Control de Ligaduras de Pagos\n";
    echo "   • Total de registros en BD: 381\n";
    echo "   • Función: Controlar la vinculación de pagos con cuentas\n";
    echo "   • Usuarios: torozco y otros\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
