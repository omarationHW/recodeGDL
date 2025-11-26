<?php
/**
 * Probar recaudadora_pagosmultfrm vía API genérica
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "========================================\n";
echo "TEST: Pagos Múltiples\n";
echo "========================================\n\n";

// Primero vamos a crear algunos registros de prueba para no afectar datos reales
echo "1️⃣ Test: Procesando 3 registros válidos...\n\n";

$registros = [
    ['cuenta' => 111111111, 'folio' => 1003, 'importe' => 1400],
    ['cuenta' => 987654321, 'folio' => 1002, 'importe' => 1400],
    ['cuenta' => 123456789, 'folio' => 1001, 'importe' => 1400]
];

$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_PAGOSMULTFRM',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_registros', 'tipo' => 'string', 'valor' => json_encode($registros)]
        ],
        'Tenant' => ''
    ]
];

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "📥 Respuesta HTTP: $httpCode\n\n";

$data = json_decode($response, true);

if (isset($data['eResponse'])) {
    $eResponse = $data['eResponse'];

    if ($eResponse['success']) {
        echo "✅ Operación exitosa\n\n";

        if (isset($eResponse['data']['result'][0])) {
            $result = $eResponse['data']['result'][0];
            echo "📊 Resultado:\n";
            echo "  Success: " . ($result['success'] ? 'true' : 'false') . "\n";
            echo "  Mensaje: {$result['mensaje']}\n";
            echo "  Procesados: {$result['procesados']}\n";
            echo "  Errores: {$result['errores']}\n\n";

            if (isset($result['detalles'])) {
                $detalles = is_string($result['detalles']) ? json_decode($result['detalles'], true) : $result['detalles'];
                echo "  Detalles:\n";
                foreach ($detalles as $detalle) {
                    echo "    - Cuenta: {$detalle['cuenta']}, Folio: {$detalle['folio']}, ";
                    echo "Status: {$detalle['status']}, Mensaje: {$detalle['mensaje']}\n";
                }
            }
        }
    } else {
        echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
    }
}

// Test 2: Con un registro con error (importe incorrecto)
echo "\n========================================\n";
echo "2️⃣ Test: Con un registro con importe incorrecto...\n\n";

$registros = [
    ['cuenta' => 358307, 'folio' => 2, 'importe' => 5000] // Importe incorrecto
];

$payload['eRequest']['Parametros'][0]['valor'] = json_encode($registros);

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);

if (isset($data['eResponse']['data']['result'][0])) {
    $result = $data['eResponse']['data']['result'][0];
    echo "📊 Resultado:\n";
    echo "  Mensaje: {$result['mensaje']}\n";
    echo "  Errores: {$result['errores']}\n";

    if (isset($result['detalles'])) {
        $detalles = is_string($result['detalles']) ? json_decode($result['detalles'], true) : $result['detalles'];
        echo "  Detalle: {$detalles[0]['mensaje']}\n";
    }
}

// Test 3: Con registro no encontrado
echo "\n========================================\n";
echo "3️⃣ Test: Con registro no encontrado...\n\n";

$registros = [
    ['cuenta' => 999999999, 'folio' => 9999, 'importe' => 100]
];

$payload['eRequest']['Parametros'][0]['valor'] = json_encode($registros);

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);

if (isset($data['eResponse']['data']['result'][0])) {
    $result = $data['eResponse']['data']['result'][0];
    echo "📊 Resultado:\n";
    echo "  Mensaje: {$result['mensaje']}\n";

    if (isset($result['detalles'])) {
        $detalles = is_string($result['detalles']) ? json_decode($result['detalles'], true) : $result['detalles'];
        echo "  Detalle: {$detalles[0]['mensaje']}\n";
    }
}

echo "\n========================================\n";
