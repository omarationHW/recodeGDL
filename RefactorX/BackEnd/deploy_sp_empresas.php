<?php
/**
 * Script para desplegar el SP recaudadora_empresas usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_empresas ===\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_empresas.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_empresas.sql\n";
echo "📂 Ruta: $sql_file\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Base de datos: padron_licencias\n\n";

try {
    // Conectar a la base de datos padron_licencias
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Ejecutar el SQL
    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_empresas desplegado exitosamente\n\n";

    // Verificar que el SP existe
    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_empresas'
          AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    } else {
        echo "⚠️  SP no encontrado después del despliegue\n\n";
        exit(1);
    }

    // Probar el SP con ejemplos
    echo "🧪 Probando el SP con ejemplos:\n\n";

    // Ejemplo 1: Buscar todos
    echo "=== EJEMPLO 1: Buscar todos (primeros 5) ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_empresas('', 0, 5)");

    if (count($result) > 0) {
        $total = $result[0]->total_count;
        echo "Total de registros en BD: $total\n";
        echo "Primeros registros:\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "$num. {$row->empresa} - RFC: {$row->rfc} - Contacto: {$row->contacto} - Estatus: {$row->estatus}\n";
        }
    } else {
        echo "No hay registros\n";
    }

    echo "\n=== EJEMPLO 2: Buscar por nombre (filtro: 'EJECUTOR') ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_empresas('EJECUTOR', 0, 5)");

    if (count($result) > 0) {
        $total = $result[0]->total_count;
        echo "Total que coinciden con 'EJECUTOR': $total\n";
        echo "Registros encontrados:\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "$num. {$row->empresa} - RFC: {$row->rfc} - Contacto: {$row->contacto} - Estatus: {$row->estatus}\n";
        }
    } else {
        echo "No hay registros con ese filtro\n";
    }

    echo "\n=== EJEMPLO 3: Buscar por categoría (filtro: 'NOTIFICADOR') ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_empresas('NOTIFICADOR', 0, 5)");

    if (count($result) > 0) {
        $total = $result[0]->total_count;
        echo "Total que coinciden con 'NOTIFICADOR': $total\n";
        echo "Registros encontrados:\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "$num. {$row->empresa} - RFC: {$row->rfc} - Contacto: {$row->contacto} - Estatus: {$row->estatus}\n";
        }
    } else {
        echo "No hay registros con ese filtro\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
