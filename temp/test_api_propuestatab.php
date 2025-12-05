<?php
// Probar la API del frontend para propuestatab
$url = 'http://127.0.0.1:8000/api/generic';

$data = [
    'operation' => 'RECAUDADORA_PROPUESTATAB',
    'database' => 'multas_reglamentos',
    'params' => [
        ['name' => 'q', 'type' => 'C', 'value' => '']
    ]
];

echo "=== PROBANDO API PROPUESTATAB ===\n\n";
echo "URL: $url\n";
echo "Datos enviados:\n";
echo json_encode($data, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$start = microtime(true);
$response = curl_exec($ch);
$end = microtime(true);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$tiempo = round(($end - $start) * 1000, 2);

echo "HTTP Code: $httpCode\n";
echo "Tiempo: {$tiempo}ms\n\n";

if (curl_errno($ch)) {
    echo "Error: " . curl_error($ch) . "\n";
} else {
    echo "=== RESPUESTA ===\n\n";

    $json = json_decode($response, true);

    if ($json) {
        echo "Estructura de la respuesta:\n";
        echo "- success: " . (isset($json['success']) ? ($json['success'] ? 'true' : 'false') : 'no definido') . "\n";
        echo "- rows: " . (isset($json['rows']) ? 'presente' : 'no presente') . "\n";

        if (isset($json['rows'])) {
            echo "- Número de registros: " . count($json['rows']) . "\n\n";

            if (!empty($json['rows'])) {
                echo "Primer registro:\n";
                print_r($json['rows'][0]);
                echo "\n";

                echo "Columnas disponibles:\n";
                foreach (array_keys($json['rows'][0]) as $col) {
                    echo "  - $col\n";
                }
            }
        }

        if (isset($json['message'])) {
            echo "\nMensaje: {$json['message']}\n";
        }

        if (isset($json['error'])) {
            echo "\nError: {$json['error']}\n";
        }

    } else {
        echo "Respuesta (no es JSON válido):\n";
        echo substr($response, 0, 500) . "\n";
    }
}

curl_close($ch);

// Probar con un filtro específico
echo "\n\n=== PROBANDO CON FILTRO 260676 ===\n\n";

$data['params'][0]['value'] = '260676';

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$start = microtime(true);
$response = curl_exec($ch);
$end = microtime(true);
$tiempo = round(($end - $start) * 1000, 2);

echo "Tiempo: {$tiempo}ms\n";

$json = json_decode($response, true);

if ($json && isset($json['rows'])) {
    echo "Registros encontrados: " . count($json['rows']) . "\n";
    if (!empty($json['rows'])) {
        echo "\nPrimer registro:\n";
        echo "  cvepago: {$json['rows'][0]['cvepago']}\n";
        echo "  cvecuenta: {$json['rows'][0]['cvecuenta']}\n";
        echo "  folio: {$json['rows'][0]['folio']}\n";
        echo "  importe: {$json['rows'][0]['importe']}\n";
    }
}

curl_close($ch);
