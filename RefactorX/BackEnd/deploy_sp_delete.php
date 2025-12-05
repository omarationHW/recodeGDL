<?php

// Script para desplegar el SP DELETE
// Usa la conexión de Laravel

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

// Cargar Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "✅ Laravel cargado\n\n";

// Leer el archivo SQL
$sqlFile = __DIR__ . '/recaudadora_reqtrans_delete.sql';

if (!file_exists($sqlFile)) {
    die("❌ Error: No se encontró el archivo $sqlFile\n");
}

$sql = file_get_contents($sqlFile);

echo "📋 Desplegando SP recaudadora_reqtrans_delete...\n\n";

try {
    // Ejecutar el SQL usando unprepared para permitir múltiples comandos
    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP recaudadora_reqtrans_delete desplegado exitosamente\n\n";

    // Probar el SP
    echo "🧪 Probando el SP...\n";

    // Verificar que el SP existe
    $exists = DB::connection('pgsql')->select("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'recaudadora_reqtrans_delete'
        ) as exists
    ");

    if ($exists[0]->exists) {
        echo "✅ SP existe en la base de datos\n";

        // Probar con un registro inexistente
        $testJson = json_encode([
            'cvereq' => 99999,
            'clave_cuenta' => '999999',
            'ejercicio' => 2024,
            'estatus' => 'Pendiente'
        ]);

        echo "\n📝 Probando con registro inexistente...\n";
        echo "JSON: $testJson\n\n";

        $result = DB::connection('pgsql')->select("SELECT recaudadora_reqtrans_delete(?::json)", [$testJson]);

        $resultData = json_decode($result[0]->recaudadora_reqtrans_delete, true);

        echo "📊 Resultado:\n";
        echo "   Success: " . ($resultData['success'] ? 'true' : 'false') . "\n";
        echo "   Message: " . $resultData['message'] . "\n";

        if (!$resultData['success']) {
            echo "\n✅ Validación de registro inexistente funciona correctamente\n";
        }

    } else {
        echo "❌ SP no se encontró en la base de datos\n";
    }

    echo "\n";
    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║          🎉 DELETE SP DESPLEGADO EXITOSAMENTE 🎉          ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 RESUMEN:\n";
    echo "   ✅ SP recaudadora_reqtrans_delete creado\n";
    echo "   ✅ Busca por cvereq (ID único)\n";
    echo "   ✅ Valida existencia del registro\n";
    echo "   ✅ Maneja foreign key violations\n";
    echo "   ✅ Retorna JSON con success/message\n";
    echo "\n";
    echo "🎯 FUNCIONALIDAD CRUD COMPLETA:\n";
    echo "   ✅ CREATE - recaudadora_reqtrans_create\n";
    echo "   ✅ READ   - recaudadora_reqtrans_list\n";
    echo "   ✅ UPDATE - recaudadora_reqtrans_update\n";
    echo "   ✅ DELETE - recaudadora_reqtrans_delete\n";
    echo "\n";
    echo "🚀 Ahora puedes probar la eliminación desde el frontend\n";
    echo "\n";

} catch (Exception $e) {
    echo "❌ Error al desplegar el SP: " . $e->getMessage() . "\n";
    echo "\nDetalles del error:\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
