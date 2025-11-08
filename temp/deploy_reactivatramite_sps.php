<?php
/**
 * Deploy Script - Stored Procedures para ReactivaTramite.vue
 *
 * Componente: ReactivaTramite.vue
 * Módulo: Padrón de Licencias
 * Funcionalidad: Reactivar trámites cancelados
 *
 * Base de Datos: padron_licencias
 * Servidor: 192.168.6.146
 * Usuario: refact
 * Password: FF)-BQk2
 *
 * SPs a desplegar:
 * 1. sp_reactivar_tramite - Reactiva un trámite cancelado
 *
 * NOTA: Este componente reutiliza los SPs de cancelaTramitefrm:
 * - sp_get_tramite_by_id (ya existe)
 * - sp_get_giro_by_id (ya existe)
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

// Bootstrap Laravel
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "\n";
echo "╔═══════════════════════════════════════════════════════════════════╗\n";
echo "║  Deploy Stored Procedures - ReactivaTramite.vue                  ║\n";
echo "║  Módulo: Padrón de Licencias                                     ║\n";
echo "╚═══════════════════════════════════════════════════════════════════╝\n";
echo "\n";

// Configurar conexión a la base de datos padron_licencias
echo "⚙️  Configurando conexión a PostgreSQL...\n";
DB::purge('pgsql');
config(['database.connections.pgsql' => [
    'driver' => 'pgsql',
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'padron_licencias',
    'username' => 'refact',
    'password' => 'FF)-BQk2',
    'charset' => 'utf8',
    'prefix' => '',
    'schema' => 'comun',
]]);
DB::reconnect('pgsql');

echo "✅ Conexión establecida\n";
echo "   Host: 192.168.6.146\n";
echo "   Database: padron_licencias\n";
echo "   Schema: comun\n";
echo "\n";

// Leer el archivo SQL
$sqlFile = __DIR__ . '/DEPLOY_REACTIVATRAMITE_SPS.sql';

if (!file_exists($sqlFile)) {
    echo "❌ ERROR: No se encontró el archivo SQL: $sqlFile\n";
    exit(1);
}

echo "📖 Leyendo archivo SQL...\n";
$sql = file_get_contents($sqlFile);

// Limpiar el SQL (remover comentarios de bloque y líneas vacías excesivas)
$sql = preg_replace('/\/\*.*?\*\//s', '', $sql);

// Separar por funciones/comandos individuales
$statements = [];
$current = '';
$inFunction = false;

foreach (explode("\n", $sql) as $line) {
    $trimmed = trim($line);

    // Ignorar comentarios de línea y líneas vacías
    if (empty($trimmed) || strpos($trimmed, '--') === 0) {
        continue;
    }

    $current .= $line . "\n";

    // Detectar inicio de función
    if (stripos($trimmed, 'CREATE OR REPLACE FUNCTION') !== false ||
        stripos($trimmed, 'DROP FUNCTION') !== false) {
        $inFunction = true;
    }

    // Detectar fin de función
    if ($inFunction && stripos($trimmed, '$$ LANGUAGE plpgsql;') !== false) {
        $statements[] = trim($current);
        $current = '';
        $inFunction = false;
    }

    // Comandos simples (COMMENT, GRANT)
    if (!$inFunction &&
        (stripos($trimmed, 'COMMENT ON') !== false ||
         stripos($trimmed, 'GRANT') !== false) &&
        substr($trimmed, -1) === ';') {
        $statements[] = trim($current);
        $current = '';
    }
}

if (!empty(trim($current))) {
    $statements[] = trim($current);
}

echo "✅ Archivo SQL cargado\n";
echo "   Statements a ejecutar: " . count($statements) . "\n";
echo "\n";

// Ejecutar cada statement
$successCount = 0;
$errorCount = 0;

foreach ($statements as $index => $statement) {
    $statement = trim($statement);
    if (empty($statement)) continue;

    // Obtener el nombre del comando para mostrar
    $commandName = 'Statement ' . ($index + 1);
    if (stripos($statement, 'DROP FUNCTION') !== false) {
        preg_match('/DROP FUNCTION.*?([a-z_]+)\(/i', $statement, $matches);
        $commandName = 'DROP ' . ($matches[1] ?? 'FUNCTION');
    } elseif (stripos($statement, 'CREATE OR REPLACE FUNCTION') !== false) {
        preg_match('/CREATE OR REPLACE FUNCTION\s+(?:comun\.)?([a-z_]+)\(/i', $statement, $matches);
        $commandName = 'CREATE ' . ($matches[1] ?? 'FUNCTION');
    } elseif (stripos($statement, 'COMMENT ON FUNCTION') !== false) {
        preg_match('/COMMENT ON FUNCTION\s+(?:comun\.)?([a-z_]+)\(/i', $statement, $matches);
        $commandName = 'COMMENT ' . ($matches[1] ?? 'FUNCTION');
    } elseif (stripos($statement, 'GRANT EXECUTE') !== false) {
        preg_match('/GRANT EXECUTE ON FUNCTION\s+(?:comun\.)?([a-z_]+)\(/i', $statement, $matches);
        $commandName = 'GRANT ' . ($matches[1] ?? 'FUNCTION');
    }

    echo "🔄 Ejecutando: $commandName\n";

    try {
        DB::statement($statement);
        echo "   ✅ Ejecutado correctamente\n";
        $successCount++;
    } catch (Exception $e) {
        echo "   ❌ ERROR: " . $e->getMessage() . "\n";
        $errorCount++;

        // Mostrar las primeras líneas del statement para debug
        $lines = explode("\n", $statement);
        echo "   📄 Statement:\n";
        foreach (array_slice($lines, 0, 3) as $line) {
            echo "      " . trim($line) . "\n";
        }
    }
    echo "\n";
}

// Resumen final
echo "╔═══════════════════════════════════════════════════════════════════╗\n";
echo "║  RESUMEN DE DEPLOYMENT                                           ║\n";
echo "╚═══════════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "✅ Exitosos: $successCount\n";
echo "❌ Errores: $errorCount\n";
echo "📊 Total: " . ($successCount + $errorCount) . "\n";
echo "\n";

if ($errorCount === 0) {
    echo "🎉 ¡Deployment completado exitosamente!\n";
    echo "\n";
    echo "📋 Stored Procedure creado:\n";
    echo "   • sp_reactivar_tramite (esquema: comun)\n";
    echo "\n";
    echo "📋 SPs reutilizados de cancelaTramitefrm:\n";
    echo "   • sp_get_tramite_by_id\n";
    echo "   • sp_get_giro_by_id\n";
    echo "\n";

    // Verificar que el SP existe
    echo "🔍 Verificando SP en la base de datos...\n";
    $sps = DB::select("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name IN ('sp_reactivar_tramite', 'sp_get_tramite_by_id', 'sp_get_giro_by_id')
        ORDER BY routine_name
    ");

    echo "   Stored Procedures encontrados:\n";
    foreach ($sps as $sp) {
        echo "   ✓ {$sp->routine_schema}.{$sp->routine_name}\n";
    }
    echo "\n";

    // Probar el SP con un ejemplo
    echo "🧪 Test rápido del SP:\n";
    echo "   Para probar, ejecuta:\n";
    echo "   SELECT * FROM comun.sp_reactivar_tramite(\n";
    echo "       <id_tramite_cancelado>,\n";
    echo "       'Motivo de reactivación',\n";
    echo "       'usuario'\n";
    echo "   );\n";
    echo "\n";

    echo "✅ ReactivaTramite.vue está listo para funcionar!\n";
} else {
    echo "⚠️  Deployment completado con errores\n";
    echo "   Por favor revisa los errores arriba\n";
}

echo "\n";
