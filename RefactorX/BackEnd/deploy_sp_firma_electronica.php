<?php
/**
 * Script para desplegar el SP recaudadora_firma_electronica usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_firma_electronica ===\n\n";

$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_firma_electronica.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_firma_electronica.sql\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Base de datos: padron_licencias\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_firma_electronica desplegado exitosamente\n\n";

    // Verificar existencia
    $sp_info = DB::connection('pgsql')->select("
        SELECT n.nspname as schema, p.proname as name,
               pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_firma_electronica' AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    }

    // Probar el SP
    echo "🧪 Probando el SP:\n\n";

    echo "=== EJEMPLO 1: Firma válida completa ===\n";
    $json1 = json_encode([
        'folio' => 'REC-2025-001',
        'usuario' => 'admin',
        'tipo' => 'recaudadora',
        'datos_firma' => 'SHA256:1a2b3c4d5e6f...'
    ]);

    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_firma_electronica(?::TEXT)
    ", [$json1]);

    if (count($result) > 0) {
        $row = $result[0];
        echo "Success: " . ($row->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$row->message}\n";
        if ($row->folio) echo "Folio: {$row->folio}\n";
        if ($row->usuario) echo "Usuario: {$row->usuario}\n";
        if ($row->fecha_firma) echo "Fecha: {$row->fecha_firma}\n";
        if ($row->tipo_documento) echo "Tipo: {$row->tipo_documento}\n";
    }

    echo "\n=== EJEMPLO 2: Firma de multa ===\n";
    $json2 = json_encode([
        'folio' => 'MULTA-2025-12345',
        'usuario' => 'jperez',
        'tipo' => 'multa',
        'datos_firma' => 'CERT:ABCD1234EFGH5678'
    ]);

    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_firma_electronica(?::TEXT)
    ", [$json2]);

    if (count($result) > 0) {
        $row = $result[0];
        echo "Success: " . ($row->success ? 'Sí' : 'No') . "\n";
        echo "Message: {$row->message}\n";
        if ($row->folio) echo "Folio: {$row->folio}\n";
    }

    echo "\n=== EJEMPLO 3: Error - falta campo requerido ===\n";
    $json3 = json_encode([
        'folio' => 'TEST-001'
        // Falta usuario y datos_firma
    ]);

    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_firma_electronica(?::TEXT)
    ", [$json3]);

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
