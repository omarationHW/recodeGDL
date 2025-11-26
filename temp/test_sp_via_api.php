<?php
/**
 * Script para probar el SP recaudadora_get_ejecutores via API
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

$payload = [
    'eRequest' => [
        'Operacion' => 'recaudadora_get_ejecutores',
        'Base' => 'multas_reglamentos',
        'Parametros' => []
    ]
];

echo "🧪 Probando SP via API Laravel...\n";
echo "URL: $apiUrl\n";
echo "Payload: " . json_encode($payload, JSON_PRETTY_PRINT) . "\n\n";

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

echo "📡 HTTP Status: $httpCode\n";
echo "📦 Respuesta:\n";

$data = json_decode($response, true);
if ($data) {
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($data['eResponse']['success']) && $data['eResponse']['success']) {
        echo "\n✅ SP funciona correctamente via API\n";

        if (isset($data['eResponse']['data']['result'])) {
            $count = count($data['eResponse']['data']['result']);
            echo "📊 Total ejecutores: $count\n";

            if ($count > 0) {
                echo "\n📋 Primeros ejecutores:\n";
                foreach (array_slice($data['eResponse']['data']['result'], 0, 3) as $idx => $row) {
                    echo "  " . ($idx + 1) . ". Clave: {$row['cveejecutor']}, Empresa: {$row['empresa']}\n";
                }
            }
        }
    } else {
        echo "\n❌ Error en la respuesta: " . ($data['eResponse']['message'] ?? 'Unknown error') . "\n";
    }
} else {
    echo "❌ No se pudo decodificar la respuesta JSON\n";
    echo "Raw response: $response\n";
}
