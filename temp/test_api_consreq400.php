<?php
// Script para probar la API de ConsReq400

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API ConsReq400 ===\n\n";

// Prueba 1: Listar todos (sin filtros) - Primera página
echo "Prueba 1: Listar requerimientos (primera página, 5 registros)\n";
echo "--------------------------------------------\n";

$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consreq400',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => ''],
            ['nombre' => 'p_ejercicio', 'tipo' => 'int', 'valor' => 0],
            ['nombre' => 'p_offset', 'tipo' => 'int', 'valor' => 0],
            ['nombre' => 'p_limit', 'tipo' => 'int', 'valor' => 5]
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
        $result = $data['eResponse']['data']['result'];
        echo "Registros en esta página: " . count($result) . "\n";
        if (count($result) > 0) {
            echo "Total de registros: " . $result[0]['total_count'] . "\n\n";

            // Mostrar primeros 3
            $limit = min(3, count($result));
            for ($i = 0; $i < $limit; $i++) {
                $row = $result[$i];
                echo "Registro " . ($i+1) . ":\n";
                echo "  Cuenta: {$row['clave_cuenta']}\n";
                echo "  Folio: {$row['folio']}\n";
                echo "  Ejercicio: {$row['ejercicio']}\n";
                echo "  Estatus: {$row['estatus']}\n";
                echo "  Fecha: {$row['fecha']}\n";
                echo "\n";
            }
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode1\n";
    echo "Respuesta: $response1\n";
}

echo "\n";

// Prueba 2: Buscar por cuenta específica
echo "Prueba 2: Buscar por cuenta '145001'\n";
echo "--------------------------------------------\n";

$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consreq400',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '145001'],
            ['nombre' => 'p_ejercicio', 'tipo' => 'int', 'valor' => 0],
            ['nombre' => 'p_offset', 'tipo' => 'int', 'valor' => 0],
            ['nombre' => 'p_limit', 'tipo' => 'int', 'valor' => 10]
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
        $result = $data['eResponse']['data']['result'];
        echo "Registros encontrados: " . count($result) . "\n";
        if (count($result) > 0) {
            echo "Total: " . $result[0]['total_count'] . "\n\n";

            $row = $result[0];
            echo "Primer registro:\n";
            echo "  Cuenta: {$row['clave_cuenta']}\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Ejercicio: {$row['ejercicio']}\n";
            echo "  Estatus: {$row['estatus']}\n";
            echo "  Fecha: {$row['fecha']}\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode2\n";
}

echo "\n\n";

// Prueba 3: Buscar por ejercicio
echo "Prueba 3: Buscar por ejercicio '50'\n";
echo "--------------------------------------------\n";

$payload3 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consreq400',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => ''],
            ['nombre' => 'p_ejercicio', 'tipo' => 'int', 'valor' => 50],
            ['nombre' => 'p_offset', 'tipo' => 'int', 'valor' => 0],
            ['nombre' => 'p_limit', 'tipo' => 'int', 'valor' => 5]
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
        $result = $data['eResponse']['data']['result'];
        echo "Registros en esta página: " . count($result) . "\n";
        if (count($result) > 0) {
            echo "Total de registros: " . $result[0]['total_count'] . "\n\n";

            // Mostrar primeros 2
            $limit = min(2, count($result));
            for ($i = 0; $i < $limit; $i++) {
                $row = $result[$i];
                echo "Registro " . ($i+1) . ":\n";
                echo "  Cuenta: {$row['clave_cuenta']}\n";
                echo "  Folio: {$row['folio']}\n";
                echo "  Ejercicio: {$row['ejercicio']}\n";
                echo "  Estatus: {$row['estatus']}\n";
                echo "\n";
            }
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode3\n";
}

curl_close($ch);

echo "\n=== FIN DE PRUEBAS ===\n";
