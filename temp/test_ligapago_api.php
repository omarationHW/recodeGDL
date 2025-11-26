<?php
/**
 * Probar recaudadora_ligapago vía API genérica
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "========================================\n";
echo "TEST: Generar Liga de Pago\n";
echo "========================================\n\n";

// Test 1: Con cuenta que tiene requerimientos
echo "1️⃣ Probando con cuenta 358307 (tiene requerimientos)...\n\n";

$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_LIGAPAGO',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '358307']
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

echo "Respuesta completa:\n";
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

if (isset($data['eResponse'])) {
    $eResponse = $data['eResponse'];

    if ($eResponse['success']) {
        echo "✅ Operación exitosa\n\n";

        if (isset($eResponse['data']['result'][0])) {
            $result = $eResponse['data']['result'][0];
            echo "📊 Resultado:\n";
            echo "  Liga: {$result['liga']}\n";
            echo "  Cuenta: {$result['cuenta']}\n";
            echo "  Total Adeudo: \${$result['total_adeudo']}\n";
            echo "  Total Requerimientos: {$result['total_requerimientos']}\n";
            echo "  Mensaje: {$result['mensaje']}\n";
        }
    } else {
        echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
    }
}

// Test 2: Con cuenta sin requerimientos
echo "\n========================================\n";
echo "2️⃣ Probando con cuenta sin requerimientos (999999)...\n\n";

$payload['eRequest']['Parametros'][0]['valor'] = '999999';

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
    echo "  Liga: " . ($result['liga'] ?? 'NULL') . "\n";
}

echo "\n========================================\n";
