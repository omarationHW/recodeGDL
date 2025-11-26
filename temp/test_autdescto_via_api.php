<?php
/**
 * Script para probar el SP recaudadora_autdescto a través de la API
 */

$baseUrl = 'http://127.0.0.1:8000/api/generic';

// Datos de prueba
$cuenta = '129976'; // Cuenta que sabemos tiene datos

$payload = [
    'eRequest' => [
        'Operacion' => 'recaudadora_autdescto',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'public',
        'Parametros' => [
            [
                'nombre' => 'p_clave_cuenta',
                'valor' => $cuenta,
                'tipo' => 'string'
            ]
        ]
    ]
];

echo "=== Probando API Genérica ===\n";
echo "URL: $baseUrl\n";
echo "SP: recaudadora_autdescto\n";
echo "Cuenta: $cuenta\n";
echo str_repeat("-", 80) . "\n\n";

$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Respuesta:\n";
echo str_repeat("-", 80) . "\n";

if ($response) {
    $data = json_decode($response, true);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($data['rows'])) {
        echo "\n✅ Total de registros: " . count($data['rows']) . "\n";
        if (count($data['rows']) > 0) {
            echo "\nPrimer registro:\n";
            echo json_encode($data['rows'][0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
        }
    }
} else {
    echo "❌ No se recibió respuesta del servidor\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
echo "Probando con cuenta inexistente (99999):\n\n";

$payload['eRequest']['Parametros'][0]['valor'] = '99999';

$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Respuesta:\n";
echo str_repeat("-", 80) . "\n";

if ($response) {
    $data = json_decode($response, true);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($data['rows'])) {
        echo "\n✅ Total de registros: " . count($data['rows']) . " (esperado: 0)\n";
    }
} else {
    echo "❌ No se recibió respuesta del servidor\n";
}
