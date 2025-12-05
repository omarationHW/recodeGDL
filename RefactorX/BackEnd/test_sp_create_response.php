<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🧪 Probando respuesta del SP CREATE...\n\n";

// Datos de prueba
$testData = [
    'clave_cuenta' => '888888',
    'folio' => 0,
    'ejercicio' => 2025,
    'estatus' => 'Pendiente'
];

$testJson = json_encode($testData);

echo "📝 JSON enviado:\n";
echo $testJson . "\n\n";

try {
    // Llamar al SP CREATE
    $result = DB::connection('pgsql')->select("SELECT recaudadora_reqtrans_create(?::json)", [$testJson]);

    echo "📊 Respuesta completa del SP:\n";
    print_r($result);
    echo "\n";

    if (!empty($result)) {
        $spResponse = $result[0]->recaudadora_reqtrans_create;

        echo "📋 Respuesta del SP (string):\n";
        echo $spResponse . "\n\n";

        $parsedResponse = json_decode($spResponse, true);

        echo "📋 Respuesta parseada:\n";
        print_r($parsedResponse);
        echo "\n";

        // Verificar el registro
        if ($parsedResponse && $parsedResponse['success']) {
            $cvereq = $parsedResponse['cvereq'];

            echo "✅ Registro creado con cvereq: $cvereq\n\n";

            // Verificar en la base de datos
            $check = DB::connection('pgsql')->select("
                SELECT cvereq, cvecuenta::TEXT as clave_cuenta, axoreq as ejercicio
                FROM catastro_gdl.reqdiftransmision
                WHERE cvereq = ?
            ", [$cvereq]);

            if (!empty($check)) {
                echo "✅ Registro encontrado en la base de datos:\n";
                print_r($check[0]);
                echo "\n";

                // Eliminar el registro de prueba
                DB::connection('pgsql')->delete("
                    DELETE FROM catastro_gdl.reqdiftransmision
                    WHERE cvereq = ?
                ", [$cvereq]);

                echo "🗑️  Registro de prueba eliminado\n\n";
            }
        } else {
            echo "❌ El SP retornó success=false\n";
            echo "Mensaje: " . ($parsedResponse['message'] ?? 'Sin mensaje') . "\n";
        }

        echo "╔════════════════════════════════════════════════════════════╗\n";
        echo "║                    ANÁLISIS DE RESPUESTA                   ║\n";
        echo "╚════════════════════════════════════════════════════════════╝\n";
        echo "\n";
        echo "🔍 Estructura de la respuesta:\n";
        echo "   - Tipo: " . gettype($result[0]) . "\n";
        echo "   - Propiedades: " . implode(', ', array_keys((array)$result[0])) . "\n";
        echo "   - Valor de 'recaudadora_reqtrans_create': " . gettype($spResponse) . "\n";
        echo "\n";
        echo "📋 Lo que el frontend debe buscar:\n";
        echo "   1. response.result[0].recaudadora_reqtrans_create (string JSON)\n";
        echo "   2. Parsear el string a objeto\n";
        echo "   3. Verificar result.success\n";
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
