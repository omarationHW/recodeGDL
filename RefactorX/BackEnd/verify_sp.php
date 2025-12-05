<?php
/**
 * Script para verificar que el SP existe en la BD
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== VERIFICACIÓN DE SP: recaudadora_empresas ===\n\n";

try {
    // Verificar en qué base de datos estamos
    $current_db = DB::connection('pgsql')->select("SELECT current_database()")[0]->current_database;
    echo "📍 Base de datos actual: $current_db\n\n";

    // Buscar el SP en todos los schemas
    echo "🔍 Buscando SP 'recaudadora_empresas' en todos los schemas...\n\n";

    $result = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments,
            pg_catalog.obj_description(p.oid, 'pg_proc') as description
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE UPPER(p.proname) = UPPER('recaudadora_empresas')
        ORDER BY n.nspname
    ");

    if (count($result) > 0) {
        echo "✅ SP encontrado en " . count($result) . " schema(s):\n\n";
        foreach ($result as $sp) {
            echo "Schema: {$sp->schema}\n";
            echo "Nombre: {$sp->name}\n";
            echo "Argumentos: {$sp->arguments}\n";
            echo "Descripción: " . ($sp->description ?? 'N/A') . "\n";
            echo "---\n\n";
        }
    } else {
        echo "❌ SP NO encontrado en ningún schema\n\n";
    }

    // Listar todos los schemas disponibles
    echo "📋 Schemas disponibles en la base de datos:\n";
    $schemas = DB::connection('pgsql')->select("
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
        ORDER BY schema_name
    ");

    foreach ($schemas as $schema) {
        echo "  - {$schema->schema_name}\n";
    }

    echo "\n";

    // Verificar la configuración de GenericController
    echo "⚙️  Configuración del módulo 'multas_reglamentos' en GenericController:\n";
    echo "  Base de datos: padron_licencias\n";
    echo "  Schema por defecto: public\n";
    echo "  Schemas permitidos: public, comun, multas_reglamentos\n\n";

    // Intentar ejecutar el SP directamente
    echo "🧪 Intentando ejecutar el SP...\n";

    // Probar con schema explícito
    try {
        $test = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_empresas('', 0, 1)");
        echo "✅ Ejecución exitosa con schema explícito 'multas_reglamentos'\n";
        echo "   Registros devueltos: " . count($test) . "\n";
    } catch (Exception $e) {
        echo "❌ Error con schema 'multas_reglamentos': " . $e->getMessage() . "\n";
    }

    echo "\n";

    // Probar sin schema explícito
    try {
        $test = DB::connection('pgsql')->select("SELECT * FROM recaudadora_empresas('', 0, 1)");
        echo "✅ Ejecución exitosa sin schema explícito\n";
        echo "   Registros devueltos: " . count($test) . "\n";
    } catch (Exception $e) {
        echo "❌ Error sin schema explícito: " . $e->getMessage() . "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
