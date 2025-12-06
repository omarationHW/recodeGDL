<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_tdm_conection...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_tdm_conection.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP CON DIFERENTES FILTROS:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Sin filtro (últimos registros)
    echo "Test 1: Sin filtro (últimas 5 conexiones)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_tdm_conection('')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Ejemplo: Usuario {$r->usuario} - " . trim($r->nombre) . "\n";
    }
    echo "\n";

    // Test 2: Buscar por usuario específico
    echo "Test 2: Buscar por usuario 'abarbosa'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_tdm_conection('abarbosa')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • ID Usuario: {$r->id_usuario}\n";
        echo "    • Usuario: " . trim($r->usuario) . "\n";
        echo "    • Nombre: " . trim($r->nombre) . "\n";
        echo "    • Estado: {$r->estado}\n";
        echo "    • ID Recaudadora: {$r->id_rec}\n";
        echo "    • Nivel: {$r->nivel}\n";
        echo "    • Perfil ID: " . ($r->perfiles_id ?? 'NULL') . "\n";
    }
    echo "\n";

    // Test 3: Buscar por otro usuario
    echo "Test 3: Buscar por usuario 'cbromero'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_tdm_conection('cbromero')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Usuario: " . trim($r->usuario) . "\n";
        echo "    • Nombre: " . trim($r->nombre) . "\n";
        echo "    • Estado: {$r->estado}\n";
        echo "    • Nivel: {$r->nivel}\n";
    }
    echo "\n";

    // Test 4: Buscar por tercer usuario
    echo "Test 4: Buscar por usuario 'lmendoza'\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_tdm_conection('lmendoza')
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        $r = $result[0];
        echo "  Resultado:\n";
        echo "    • Usuario: " . trim($r->usuario) . "\n";
        echo "    • Nombre: " . trim($r->nombre) . "\n";
        echo "    • Estado: {$r->estado}\n";
        echo "    • Nivel: {$r->nivel}\n";
    }
    echo "\n";

    // Test 5: Buscar por estado activo
    echo "Test 5: Buscar por estado 'A' (activos)\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_tdm_conection('A')
        LIMIT 5
    ");
    echo "  Registros encontrados: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "  Primeros resultados:\n";
        foreach ($result as $i => $r) {
            if ($i >= 3) break;
            echo "    • " . trim($r->usuario) . " - " . trim($r->nombre) . "\n";
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
        SELECT *
        FROM comun.conexion
        ORDER BY id_usuario DESC
        LIMIT 3
    ");

    foreach ($ejemplos as $i => $ej) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Filtro: '" . trim($ej->usuario) . "' (buscar por usuario)\n";
        echo "  Resultado esperado:\n";
        echo "    • ID Usuario: {$ej->id_usuario}\n";
        echo "    • Usuario: " . trim($ej->usuario) . "\n";
        echo "    • Nombre: " . trim($ej->nombre) . "\n";
        echo "    • Estado: {$ej->estado}\n";
        echo "    • ID Recaudadora: {$ej->id_rec}\n";
        echo "    • Nivel: {$ej->nivel}\n";
        echo "    • Perfil ID: " . ($ej->perfiles_id ?? 'NULL') . "\n";
        echo "\n";
    }

    echo "💡 OTROS FILTROS PARA PROBAR:\n";
    echo "  • Vacío (sin filtro) → Muestra todas las conexiones\n";
    echo "  • 'A' → Busca usuarios activos\n";
    echo "  • '5' → Busca por nivel 5\n";
    echo "  • '1' → Busca por recaudadora 1\n";
    echo "  • Nombre parcial → Busca por nombre (ej: 'Alejandro')\n";
    echo "\n";
    echo "📊 SISTEMA: Conexiones TDM (Terminal Data Monitor)\n";
    echo "   • Total de registros en BD: 446\n";
    echo "   • Función: Gestionar usuarios y conexiones del sistema\n";
    echo "   • Estados: A=Activo, B=Bloqueado, I=Inactivo\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
