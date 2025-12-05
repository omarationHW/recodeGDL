<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sgcv2...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sgcv2.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros)
    echo "Test 1: Sin filtro (últimos 5 registros)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sgcv2('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: ID {$r->id} - Ejercicio {$r->ejercicio} - Número {$r->numero}\n";
        echo "  Nombre: {$r->nombre_generico}\n";
    }
    echo "\n";

    // Test 2: Buscar por ejercicio 2021
    echo "Test 2: Buscar por ejercicio '2021'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sgcv2('2021')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado: ID {$r->id}\n";
        echo "  Ejercicio: {$r->ejercicio}\n";
        echo "  Nombre: {$r->nombre_generico}\n";
        echo "  Usuario: {$r->usuario}\n";
    }
    echo "\n";

    // Test 3: Buscar por número 2765
    echo "Test 3: Buscar por número '2765'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sgcv2('2765')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado: ID {$r->id}\n";
        echo "  Número: {$r->numero}\n";
        echo "  Nombre: {$r->nombre_generico}\n";
        echo "  Fecha: {$r->fecha_documento}\n";
    }
    echo "\n";

    // Test 4: Buscar por usuario
    echo "Test 4: Buscar por usuario 'esgomez'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sgcv2('esgomez')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "  Primeros resultados:\n";
        foreach ($result as $i => $r) {
            if ($i >= 3) break;
            echo "    • ID {$r->id} - {$r->nombre_generico} - Usuario: {$r->usuario}\n";
        }
    }
    echo "\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 DESPLIEGUE EXITOSO 🎉                      ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 EJEMPLOS PARA PROBAR EN EL FRONTEND:\n\n";

    // Obtener 3 ejemplos concretos
    $ejemplos = DB::connection('pgsql')->select("
        SELECT
            id,
            ejercicico,
            numero,
            nombre_generico,
            fec_docto,
            usuario_mov
        FROM comun.t42_control
        ORDER BY id DESC
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '{$ej->numero}' (buscar por número)\n";
        echo "  Resultado esperado: ID {$ej->id}\n";
        echo "  Ejercicio: {$ej->ejercicico}\n";
        echo "  Nombre: {$ej->nombre_generico}\n";
        echo "  Fecha: {$ej->fec_docto}\n";
        echo "  Usuario: " . trim($ej->usuario_mov) . "\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra últimos 100 registros\n";
    echo "  • '2021' → Busca por ejercicio fiscal\n";
    echo "  • 'DJ/OP' → Busca por nombre del documento\n";
    echo "  • 'esgomez' → Busca por usuario\n";
    echo "\n";
    echo "📊 SISTEMA: Control de Trámites y Documentos (T42)\n";
    echo "   • Total de registros en BD: 71,983\n";
    echo "   • Ejercicios: 2021 y anteriores\n";
    echo "   • Usuarios activos en el sistema\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
