<?php
/**
 * Script para probar el endpoint de ReqFrm
 */

$url = "http://127.0.0.1:8000/api/generic";

// Datos de prueba (cuenta nueva que no existe)
$datos = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_REQ_FRM_SAVE',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_registro',
                'tipo' => 'string',
                'valor' => json_encode([
                    'clave_cuenta' => 444555666,
                    'folio' => 2001,
                    'ejercicio' => 2025
                ])
            ]
        ]
    ]
];

echo "=== PRUEBA DE ENDPOINT REQ_FRM_SAVE ===\n\n";
echo "URL: $url\n";
echo "Operación: RECAUDADORA_REQ_FRM_SAVE\n";
echo "Base: multas_reglamentos\n\n";

echo "Datos a enviar:\n";
echo json_encode($datos, JSON_PRETTY_PRINT) . "\n\n";

echo "Enviando petición...\n";
echo str_repeat("-", 80) . "\n";

// Inicializar curl
$ch = curl_init($url);

// Configurar opciones
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($datos));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

// Ejecutar petición
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

// Mostrar resultado
if ($error) {
    echo "ERROR DE CURL: $error\n";
    exit(1);
}

echo "HTTP Code: $httpCode\n";
echo "Respuesta:\n";

if ($response) {
    $responseData = json_decode($response, true);
    echo json_encode($responseData, JSON_PRETTY_PRINT) . "\n\n";

    if (isset($responseData['eResponse'])) {
        $eResponse = $responseData['eResponse'];

        if (isset($eResponse['success']) && $eResponse['success']) {
            echo "✅ ÉXITO: Requerimiento guardado correctamente\n";

            if (isset($eResponse['data']['result'][0])) {
                $result = $eResponse['data']['result'][0];
                echo "   Mensaje: {$result['mensaje']}\n";
                echo "   ID Requerimiento: {$result['cvereq']}\n";
            }
        } else {
            echo "❌ ERROR: {$eResponse['message']}\n";

            if (isset($eResponse['data']['result'][0])) {
                $result = $eResponse['data']['result'][0];
                echo "   Detalle: {$result['mensaje']}\n";
            }
        }
    }
} else {
    echo "Sin respuesta\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
