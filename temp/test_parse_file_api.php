<?php
/**
 * Script para probar el SP recaudadora_parse_file via API
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

$testFileContent = "12345|100|2023\n67890|200|2024\n11111|300|2025";

$payload = [
    'eRequest' => [
        'Operacion' => 'recaudadora_parse_file',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_file_content',
                'tipo' => 'string',
                'valor' => $testFileContent
            ]
        ]
    ]
];

echo "🧪 Probando SP recaudadora_parse_file via API Laravel...\n";
echo "URL: $apiUrl\n";
echo "Archivo de prueba (3 líneas):\n";
echo str_replace("\n", "\n  ", $testFileContent) . "\n\n";

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
            echo "📊 Total folios parseados: $count\n";

            if ($count > 0) {
                echo "\n📋 Folios parseados:\n";
                foreach ($data['eResponse']['data']['result'] as $idx => $row) {
                    echo "  " . ($idx + 1) . ". Cuenta: {$row['clave_cuenta']}, Folio: {$row['folio']}, Año: {$row['anio_folio']}, Propietario: {$row['propietario']}\n";
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
