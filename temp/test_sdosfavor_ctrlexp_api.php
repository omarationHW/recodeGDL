<?php
/**
 * Probar recaudadora_sdosfavor_ctrlexp vía API genérica
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "========================================\n";
echo "TEST: Control de Expedientes Saldos Favor\n";
echo "========================================\n\n";

$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_SDOSFAVOR_CTRLEXP',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '295685']
        ],
        'Tenant' => ''
    ]
];

echo "📤 Enviando request...\n";
echo "Cuenta: 295685\n\n";

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

if ($response === false) {
    echo "❌ Error al ejecutar curl\n";
    exit(1);
}

$data = json_decode($response, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "❌ Error al decodificar JSON: " . json_last_error_msg() . "\n";
    echo "Respuesta raw:\n$response\n";
    exit(1);
}

echo "Respuesta:\n";
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

if (isset($data['eResponse'])) {
    $eResponse = $data['eResponse'];

    if ($eResponse['success']) {
        echo "✅ Operación exitosa\n\n";

        if (isset($eResponse['data']['result'])) {
            $result = $eResponse['data']['result'];
            echo "📊 Expedientes encontrados: " . count($result) . "\n\n";

            if (count($result) > 0) {
                echo "📋 Primer expediente:\n";
                foreach ($result[0] as $key => $value) {
                    echo "  $key: " . ($value ?? 'NULL') . "\n";
                }
            }
        }
    } else {
        echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
    }
} else {
    echo "❌ Formato de respuesta inesperado\n";
}

echo "\n========================================\n";
