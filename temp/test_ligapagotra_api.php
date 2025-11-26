<?php
/**
 * Probar recaudadora_ligapagotra vía API genérica
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "========================================\n";
echo "TEST: Generar Liga de Pago por Trámite\n";
echo "========================================\n\n";

// Test 1: Con trámite válido
echo "1️⃣ Probando con trámite 349786 (ALTA DE LICENCIA WEB)...\n\n";

$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_LIGAPAGOTRA',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_tramite', 'tipo' => 'string', 'valor' => '349786']
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
            echo "  Liga: {$result['liga']}\n";
            echo "  Trámite: {$result['tramite']}\n";
            echo "  Tipo: {$result['tipo_tramite']} - {$result['descripcion']}\n";
            echo "  Propietario: {$result['propietario']}\n";
            echo "  Actividad: {$result['actividad']}\n";
            echo "  Cuenta: {$result['cuenta']}\n";
            echo "  Total: \${$result['total_importe']}\n";
            echo "  Mensaje: {$result['mensaje']}\n";
        }
    } else {
        echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
    }
}

// Test 2: Con otro trámite
echo "\n========================================\n";
echo "2️⃣ Probando con trámite 349785 (ALTA DE LICENCIA)...\n\n";

$payload['eRequest']['Parametros'][0]['valor'] = '349785';

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
    echo "  Trámite: {$result['tramite']}\n";
    echo "  Tipo: {$result['descripcion']}\n";
    echo "  Total: \${$result['total_importe']}\n";
    echo "  Liga: {$result['liga']}\n";
}

// Test 3: Con trámite inexistente
echo "\n========================================\n";
echo "3️⃣ Probando con trámite inexistente (999999)...\n\n";

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
