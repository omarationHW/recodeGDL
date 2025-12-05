<?php
/**
 * Script para desplegar el SP recaudadora_entregafrm usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_entregafrm ===\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_entregafrm.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_entregafrm.sql\n";
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
    echo "✅ SP recaudadora_entregafrm desplegado exitosamente\n\n";

    // Verificar que el SP existe
    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_entregafrm'
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

    // Ejemplo 1: JSON válido con todos los campos
    echo "=== EJEMPLO 1: JSON válido completo ===\n";
    $json1 = json_encode([
        'folio' => 12345,
        'ejecutor' => 380,
        'recaudadora' => 1,
        'fecha' => '2025-12-02',
        'usuario' => 'ADMIN'
    ]);
    echo "JSON: $json1\n";

    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_entregafrm(?)", [$json1]);

    if (count($result) > 0) {
        $row = $result[0];
        echo "Success: " . ($row->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$row->message}\n";
        echo "Folio: {$row->folio}\n";
        echo "Ejecutor: {$row->ejecutor}\n";
        echo "Fecha: {$row->fecha_entrega}\n";
    }

    echo "\n=== EJEMPLO 2: JSON mínimo (solo folio y ejecutor) ===\n";
    $json2 = json_encode([
        'folio' => 67890,
        'ejecutor' => 350
    ]);
    echo "JSON: $json2\n";

    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_entregafrm(?)", [$json2]);

    if (count($result) > 0) {
        $row = $result[0];
        echo "Success: " . ($row->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$row->message}\n";
        echo "Folio: {$row->folio}\n";
        echo "Ejecutor: {$row->ejecutor}\n";
    }

    echo "\n=== EJEMPLO 3: JSON inválido (ejecutor no existe) ===\n";
    $json3 = json_encode([
        'folio' => 99999,
        'ejecutor' => 999999
    ]);
    echo "JSON: $json3\n";

    $result = DB::connection('pgsql')->select("SELECT * FROM multas_reglamentos.recaudadora_entregafrm(?)", [$json3]);

    if (count($result) > 0) {
        $row = $result[0];
        echo "Success: " . ($row->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$row->message}\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
