<?php
// Script para simular la llamada del frontend al API

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API consmulpagos ===\n\n";

// Prueba 1: Buscar pago específico
echo "Prueba 1: Buscar pago con cvepago = 13878081\n";
echo "--------------------------------------------\n";

$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consmulpagos',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_clave_cuenta',
                'tipo' => 'string',
                'valor' => '13878081'
            ]
        ],
        'Tenant' => ''
    ]
];

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload1));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response1 = curl_exec($ch);
$httpCode1 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode1 == 200) {
    $data = json_decode($response1, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n";
        echo "Registros encontrados: " . count($data['eResponse']['data']['result']) . "\n";
        if (count($data['eResponse']['data']['result']) > 0) {
            $first = $data['eResponse']['data']['result'][0];
            echo "Primer registro:\n";
            echo "  cvepago: {$first['cvepago']}\n";
            echo "  contribuyente: {$first['contribuyente']}\n";
            echo "  fecha: {$first['fecha']}\n";
            echo "  importe: {$first['importe']}\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode1\n";
    echo "Respuesta: $response1\n";
}

echo "\n\n";

// Prueba 2: Listar todos (sin parámetro)
echo "Prueba 2: Listar todos los pagos (sin parámetro)\n";
echo "--------------------------------------------\n";

$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consmulpagos',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_clave_cuenta',
                'tipo' => 'string',
                'valor' => ''
            ]
        ],
        'Tenant' => ''
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload2));
$response2 = curl_exec($ch);
$httpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode2 == 200) {
    $data = json_decode($response2, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n";
        echo "Registros encontrados: " . count($data['eResponse']['data']['result']) . "\n";

        // Mostrar primeros 3
        $limit = min(3, count($data['eResponse']['data']['result']));
        for ($i = 0; $i < $limit; $i++) {
            $row = $data['eResponse']['data']['result'][$i];
            echo "\nRegistro " . ($i+1) . ":\n";
            echo "  cvepago: {$row['cvepago']}\n";
            echo "  contribuyente: {$row['contribuyente']}\n";
            echo "  fecha: {$row['fecha']}\n";
            echo "  importe: {$row['importe']}\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode2\n";
    echo "Respuesta: $response2\n";
}

curl_close($ch);

echo "\n\n=== FIN DE PRUEBAS ===\n";
