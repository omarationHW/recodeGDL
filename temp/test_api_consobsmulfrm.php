<?php
// Script para probar la API de consobsmulfrm

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API consobsmulfrm ===\n\n";

// Prueba 1: Buscar por palabra en observación
echo "Prueba 1: Buscar multas con la palabra 'LICENCIA'\n";
echo "--------------------------------------------\n";

$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consobsmulfrm',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_filtro',
                'tipo' => 'string',
                'valor' => 'LICENCIA'
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

        // Mostrar primeros 3
        $limit = min(3, count($data['eResponse']['data']['result']));
        for ($i = 0; $i < $limit; $i++) {
            $row = $data['eResponse']['data']['result'][$i];
            echo "\nRegistro " . ($i+1) . ":\n";
            echo "  id_multa: {$row['id_multa']}\n";
            echo "  contribuyente: {$row['contribuyente']}\n";
            echo "  num_acta: {$row['num_acta']}\n";
            echo "  observacion: " . substr($row['observacion'], 0, 80) . "...\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode1\n";
    echo "Respuesta: $response1\n";
}

echo "\n\n";

// Prueba 2: Buscar por número de acta
echo "Prueba 2: Buscar multas con número de acta '1523'\n";
echo "--------------------------------------------\n";

$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consobsmulfrm',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_filtro',
                'tipo' => 'string',
                'valor' => '1523'
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

        if (count($data['eResponse']['data']['result']) > 0) {
            $row = $data['eResponse']['data']['result'][0];
            echo "\nPrimer registro:\n";
            echo "  id_multa: {$row['id_multa']}\n";
            echo "  contribuyente: {$row['contribuyente']}\n";
            echo "  num_acta: {$row['num_acta']}\n";
            echo "  axo_acta: {$row['axo_acta']}\n";
            echo "  observacion: " . substr($row['observacion'], 0, 80) . "...\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode2\n";
}

echo "\n\n";

// Prueba 3: Listar todas (sin filtro)
echo "Prueba 3: Listar todas las multas con observaciones (sin filtro)\n";
echo "--------------------------------------------\n";

$payload3 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consobsmulfrm',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_filtro',
                'tipo' => 'string',
                'valor' => ''
            ]
        ],
        'Tenant' => ''
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload3));
$response3 = curl_exec($ch);
$httpCode3 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode3 == 200) {
    $data = json_decode($response3, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n";
        echo "Registros encontrados: " . count($data['eResponse']['data']['result']) . "\n";

        // Mostrar primeros 2
        $limit = min(2, count($data['eResponse']['data']['result']));
        for ($i = 0; $i < $limit; $i++) {
            $row = $data['eResponse']['data']['result'][$i];
            echo "\nRegistro " . ($i+1) . ":\n";
            echo "  id_multa: {$row['id_multa']}\n";
            echo "  contribuyente: {$row['contribuyente']}\n";
            echo "  num_acta: {$row['num_acta']}\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode3\n";
}

curl_close($ch);

echo "\n\n=== FIN DE PRUEBAS ===\n";
