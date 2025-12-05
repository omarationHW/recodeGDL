<?php
/**
 * Script para liberar conexiones idle de PostgreSQL
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== LIBERANDO CONEXIONES IDLE EN POSTGRESQL ===\n\n";

try {
    // Ver conexiones actuales
    $connections = DB::connection('pgsql')->select("
        SELECT
            pid,
            usename,
            application_name,
            client_addr,
            state,
            state_change,
            NOW() - state_change as idle_time
        FROM pg_stat_activity
        WHERE datname = 'padron_licencias'
        ORDER BY state_change
    ");

    echo "📊 Conexiones actuales:\n";
    echo "Total: " . count($connections) . " conexiones\n\n";

    $idle_count = 0;
    $active_count = 0;
    $idle_pids = [];

    foreach ($connections as $conn) {
        if ($conn->state === 'idle') {
            $idle_count++;
            $idle_pids[] = $conn->pid;
            echo "  🔴 PID {$conn->pid}: {$conn->usename} - {$conn->state} ({$conn->application_name})\n";
        } else {
            $active_count++;
            echo "  🟢 PID {$conn->pid}: {$conn->usename} - {$conn->state} ({$conn->application_name})\n";
        }
    }

    echo "\n📈 Resumen:\n";
    echo "  - Activas: $active_count\n";
    echo "  - Idle: $idle_count\n\n";

    // Matar conexiones idle (excepto la actual)
    if ($idle_count > 0) {
        echo "🔧 Terminando conexiones idle...\n";

        foreach ($idle_pids as $pid) {
            try {
                DB::connection('pgsql')->statement("SELECT pg_terminate_backend($pid)");
                echo "  ✅ Terminada PID $pid\n";
            } catch (Exception $e) {
                // Puede fallar si es nuestra propia conexión
                echo "  ⚠️  No se pudo terminar PID $pid (puede ser la conexión actual)\n";
            }
        }

        echo "\n✅ Conexiones idle liberadas\n";
    } else {
        echo "ℹ️  No hay conexiones idle para liberar\n";
    }

    // Verificar conexiones restantes
    echo "\n📊 Verificando conexiones restantes...\n";
    $remaining = DB::connection('pgsql')->select("
        SELECT COUNT(*) as total
        FROM pg_stat_activity
        WHERE datname = 'padron_licencias'
    ");
    echo "Conexiones restantes: " . $remaining[0]->total . "\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
