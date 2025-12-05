<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🧪 PRUEBA DE CAMBIO DE PASSWORD\n\n";

try {
    // Test con usuario real
    echo "═══════════════════════════════════════════════════════════\n";
    echo "Test: Cambiar password del usuario 'aacevedo'\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $result = DB::connection('pgsql')->select("
        SELECT * FROM recaudadora_sfrm_chgpass('aacevedo', 'test123')
    ");

    if (count($result) > 0) {
        $r = $result[0];
        echo "✅ Respuesta del SP:\n";
        echo "   Success: " . ($r->success ? 'true' : 'false') . "\n";
        echo "   Message: {$r->message}\n";
        echo "   Usuario: {$r->usuario}\n\n";

        if ($r->success) {
            echo "╔════════════════════════════════════════════════════════════╗\n";
            echo "║            ✅ PASSWORD CAMBIADO EXITOSAMENTE ✅            ║\n";
            echo "╚════════════════════════════════════════════════════════════╝\n";
            echo "\n";
            echo "🎯 Ahora puedes probar en el frontend:\n";
            echo "   Usuario: aacevedo\n";
            echo "   Password: test123\n";
            echo "\n";
        } else {
            echo "❌ ERROR: {$r->message}\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
