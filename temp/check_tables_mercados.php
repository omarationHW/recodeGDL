<?php
// Cambiar al directorio de Laravel
chdir(__DIR__ . '/../RefactorX/BackEnd');

// Incluir el autoloader de Laravel
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

// Cargar la aplicación Laravel
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "VERIFICACIÓN DE TABLAS EN BASE MERCADOS\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    echo "1. Buscando tablas con 'local' en el nombre...\n\n";
    $tables = DB::connection($connection)->select("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%local%'
        AND table_type = 'BASE TABLE'
        ORDER BY table_schema, table_name
    ");

    foreach ($tables as $table) {
        echo "   - {$table->table_schema}.{$table->table_name}\n";
    }

    echo "\n2. Verificando esquemas disponibles...\n\n";
    $schemas = DB::connection($connection)->select("
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schema_name
    ");

    foreach ($schemas as $schema) {
        echo "   - {$schema->schema_name}\n";
    }

    echo "\n3. Verificando search_path actual...\n\n";
    $searchPath = DB::connection($connection)->select("SHOW search_path");
    echo "   search_path: " . $searchPath[0]->search_path . "\n\n";

    echo "\n4. Buscando tablas ta_11 en todos los esquemas...\n\n";
    $ta11Tables = DB::connection($connection)->select("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE 'ta_11_%'
        AND table_type = 'BASE TABLE'
        ORDER BY table_schema, table_name
        LIMIT 30
    ");

    foreach ($ta11Tables as $table) {
        echo "   - {$table->table_schema}.{$table->table_name}\n";
    }

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
