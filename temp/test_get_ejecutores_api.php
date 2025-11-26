<?php
/**
 * Test del SP recaudadora_get_ejecutores vía API
 */

echo "=== TEST SP RECAUDADORA_GET_EJECUTORES VÍA API ===\n\n";

$url = 'http://127.0.0.1:8000/api/generic';
$data = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_GET_EJECUTORES',
        'Base' => 'multas_reglamentos',
        'Parametros' => [],
        'Tenant' => ''
    ]
];

echo "1. Enviando request a la API...\n";
echo "   URL: $url\n";
echo "   Operación: RECAUDADORA_GET_EJECUTORES\n\n";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "2. Respuesta de la API:\n";
echo "   HTTP Code: $http_code\n";

if ($error) {
    echo "   ✗ Error cURL: $error\n";
    exit(1);
}

if ($http_code !== 200) {
    echo "   ✗ Error HTTP $http_code\n";
    echo "\nRespuesta completa:\n";
    echo $response . "\n";
    exit(1);
}

echo "   ✓ API respondió correctamente\n\n";

$json = json_decode($response, true);

if (!$json) {
    echo "   ✗ Error al parsear JSON\n";
    echo "   Respuesta: " . substr($response, 0, 500) . "\n";
    exit(1);
}

echo "3. Estructura de la respuesta:\n";
echo json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

// Intentar extraer los ejecutores
$ejecutores = null;

if (isset($json['eResponse']['data']['result'])) {
    $ejecutores = $json['eResponse']['data']['result'];
} elseif (isset($json['result'])) {
    $ejecutores = $json['result'];
} elseif (isset($json['data'])) {
    $ejecutores = $json['data'];
}

if ($ejecutores === null) {
    echo "⚠️  No se pudo encontrar los ejecutores en la respuesta\n";
    exit(0);
}

if (!is_array($ejecutores)) {
    echo "⚠️  Los ejecutores no son un array\n";
    exit(0);
}

echo "4. Ejecutores encontrados: " . count($ejecutores) . "\n\n";

if (count($ejecutores) > 0) {
    echo "Primeros 5 ejecutores:\n";
    foreach (array_slice($ejecutores, 0, 5) as $ej) {
        echo "   - ID: " . ($ej['cveejecutor'] ?? 'N/A') . " | Empresa: " . ($ej['empresa'] ?? 'N/A') . "\n";
    }
} else {
    echo "⚠️  No hay ejecutores en la base de datos\n";
}

echo "\n✅ Test completado\n";
