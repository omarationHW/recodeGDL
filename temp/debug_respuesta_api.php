<?php
// Debug completo de la respuesta del API
echo "═══ DEBUG COMPLETO DE LA RESPUESTA ═══\n\n";

$api_url = "http://127.0.0.1:8000/api/generic";
$payload = [
    'eRequest' => [
        'Operacion' => 'recaudadora_req',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            'p_clave_cuenta' => '',
            'p_ejercicio' => 2025
        ]
    ]
];

$ch = curl_init($api_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

echo "RESPUESTA COMPLETA (JSON):\n";
echo $response . "\n\n";

$data = json_decode($response, true);

echo "ESTRUCTURA DE DATOS:\n";
print_r($data);

echo "\n\nANÁLISIS:\n";
if (isset($data['eResponse'])) {
    echo "✓ eResponse encontrado\n";

    if (isset($data['eResponse']['data'])) {
        echo "✓ eResponse.data encontrado\n";
        echo "  Tipo: " . gettype($data['eResponse']['data']) . "\n";

        if (is_array($data['eResponse']['data'])) {
            echo "  Elementos: " . count($data['eResponse']['data']) . "\n";

            if (count($data['eResponse']['data']) > 0) {
                echo "\n  PRIMER ELEMENTO:\n";
                print_r($data['eResponse']['data'][0]);
            }
        }
    }
}
