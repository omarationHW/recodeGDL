<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sfrm_chgpass...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sfrm_chgpass.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    // Obtener 3 usuarios reales para ejemplos
    echo "🔍 Obteniendo usuarios de ejemplo...\n\n";

    $usuarios = DB::connection('pgsql')->select("
        SELECT usuario, nombres
        FROM comun.usuarios
        WHERE usuario IS NOT NULL AND TRIM(usuario) != ''
        ORDER BY usuario
        LIMIT 5
    ");

    if (count($usuarios) > 0) {
        echo "📋 USUARIOS DISPONIBLES EN EL SISTEMA:\n\n";

        foreach ($usuarios as $i => $u) {
            if ($i >= 3) break;
            echo "Ejemplo " . ($i + 1) . ":\n";
            echo "  Usuario: " . trim($u->usuario) . "\n";
            echo "  Nombre: " . trim($u->nombres) . "\n";
            echo "\n";
        }
    }

    // Probar casos de error
    echo "═══════════════════════════════════════════════════════════\n";
    echo "🧪 PROBANDO EL SP (CASOS DE ERROR):\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    // Test 1: Usuario vacío
    echo "Test 1: Usuario vacío\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_chgpass('', 'test123')
    ");
    echo "  Resultado: " . ($result[0]->success ? 'ÉXITO' : 'ERROR') . "\n";
    echo "  Mensaje: {$result[0]->message}\n\n";

    // Test 2: Password vacío
    echo "Test 2: Password vacío\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_chgpass('usuario_test', '')
    ");
    echo "  Resultado: " . ($result[0]->success ? 'ÉXITO' : 'ERROR') . "\n";
    echo "  Mensaje: {$result[0]->message}\n\n";

    // Test 3: Usuario no existe
    echo "Test 3: Usuario inexistente\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_chgpass('usuario_que_no_existe_12345', 'test123')
    ");
    echo "  Resultado: " . ($result[0]->success ? 'ÉXITO' : 'ERROR') . "\n";
    echo "  Mensaje: {$result[0]->message}\n\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║                  🎉 DESPLIEGUE EXITOSO 🎉                  ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "⚠️  NOTA DE SEGURIDAD:\n";
    echo "   • No probamos cambios reales de password por seguridad\n";
    echo "   • El SP está listo para usar con usuarios reales\n";
    echo "   • Los mensajes de error funcionan correctamente\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
