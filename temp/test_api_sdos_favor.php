<?php
/**
 * Script para probar el API de saldos a favor
 * Simula lo que hace el frontend
 */

// Parámetros de prueba
$url = "http://127.0.0.1:8000/api/generic/execute";
$database = "multas_reglamentos";
$operacion = "RECAUDADORA_CONSULTA_SDOS_FAVOR";

// Test 1: Con parámetros del usuario (probablemente sin resultados)
echo "🧪 TEST 1: Con parámetros del usuario\n";
echo "======================================\n";

$payload1 = [
    'database' => $database,
    'operacion' => $operacion,
    'parameters' => [
        ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '21432'],
        ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 2025],
        ['nombre' => 'p_folio', 'tipo' => 'integer', 'valor' => 5]
    ]
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload1));

$response1 = curl_exec($ch);
$httpCode1 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Code: $httpCode1\n";
echo "Respuesta:\n";
echo json_encode(json_decode($response1), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
echo "\n\n";

// Test 2: Sin filtros (debería traer resultados)
echo "🧪 TEST 2: Sin filtros (debería traer resultados)\n";
echo "==================================================\n";

$payload2 = [
    'database' => $database,
    'operacion' => $operacion,
    'parameters' => [
        ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => null],
        ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => null],
        ['nombre' => 'p_folio', 'tipo' => 'integer', 'valor' => null]
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload2));
$response2 = curl_exec($ch);
$httpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Code: $httpCode2\n";
echo "Respuesta:\n";
echo json_encode(json_decode($response2), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
echo "\n\n";

// Test 3: Con cuenta que existe (295685)
echo "🧪 TEST 3: Con cuenta que existe (295685, folio 1310, ejercicio 2024)\n";
echo "=======================================================================\n";

$payload3 = [
    'database' => $database,
    'operacion' => $operacion,
    'parameters' => [
        ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '295685'],
        ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 2024],
        ['nombre' => 'p_folio', 'tipo' => 'integer', 'valor' => 1310]
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload3));
$response3 = curl_exec($ch);
$httpCode3 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Code: $httpCode3\n";
echo "Respuesta:\n";
$decoded = json_decode($response3, true);
echo json_encode($decoded, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
echo "\n\n";

// Analizar estructura
if ($decoded && isset($decoded['eResponse'])) {
    echo "📊 ANÁLISIS DE ESTRUCTURA:\n";
    echo "==========================\n";
    echo "✅ eResponse existe\n";

    if (isset($decoded['eResponse']['data'])) {
        echo "✅ eResponse.data existe\n";

        if (isset($decoded['eResponse']['data']['result'])) {
            echo "✅ eResponse.data.result existe\n";
            $result = $decoded['eResponse']['data']['result'];
            echo "   Tipo: " . gettype($result) . "\n";
            echo "   Cantidad de elementos: " . (is_array($result) ? count($result) : 'N/A') . "\n";

            if (is_array($result) && count($result) > 0) {
                echo "   Primer elemento:\n";
                echo "   " . json_encode($result[0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
            }
        }
    }
}

curl_close($ch);
