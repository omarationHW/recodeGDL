<?php
// Probar la integración completa: Frontend -> API -> SP
// Simula exactamente cómo el componente Vue llama al backend

$apiUrl = 'http://127.0.0.1:8000/api/generic';

// EJEMPLO 1: Actualizar concepto existente
echo "=== EJEMPLO 1: Actualizar concepto existente (ID 4) ===\n";

$ejemplo1 = [
    [
        "cveconcepto" => 4,
        "descripcion" => "PAGO DE DIVERSOS TEST API",
        "ncorto" => "DIV-API",
        "cvegrupo" => 1
    ]
];

$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_publicos_upd',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_datos',
                'valor' => json_encode($ejemplo1),
                'tipo' => 'string'
            ]
        ],
        'Tenant' => ''
    ]
];

echo "Payload enviado:\n";
echo json_encode($payload1, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

$ch1 = curl_init($apiUrl);
curl_setopt($ch1, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch1, CURLOPT_POST, true);
curl_setopt($ch1, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch1, CURLOPT_POSTFIELDS, json_encode($payload1));

$response1 = curl_exec($ch1);
$httpCode1 = curl_getinfo($ch1, CURLINFO_HTTP_CODE);
curl_close($ch1);

echo "HTTP Code: $httpCode1\n";
echo "Response:\n";

if ($response1) {
    $decoded1 = json_decode($response1, true);
    echo json_encode($decoded1, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($decoded1['eResponse']['success']) && $decoded1['eResponse']['success']) {
        echo "\n✅ EJEMPLO 1 EXITOSO\n";
        if (isset($decoded1['eResponse']['data']) && is_array($decoded1['eResponse']['data'])) {
            foreach ($decoded1['eResponse']['data'] as $row) {
                echo "  - ID: {$row['cveconcepto']} | Acción: {$row['accion']} | Resultado: {$row['resultado']}\n";
            }
        }
    } else {
        echo "\n❌ EJEMPLO 1 FALLÓ\n";
    }
} else {
    echo "❌ Sin respuesta\n";
}

// EJEMPLO 2: Insertar nuevo concepto
echo "\n\n=== EJEMPLO 2: Insertar nuevo concepto ===\n";

$ejemplo2 = [
    [
        "cveconcepto" => 0,
        "descripcion" => "CONCEPTO PRUEBA API",
        "ncorto" => "API-TEST",
        "cvegrupo" => 2
    ]
];

$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_publicos_upd',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_datos',
                'valor' => json_encode($ejemplo2),
                'tipo' => 'string'
            ]
        ],
        'Tenant' => ''
    ]
];

$ch2 = curl_init($apiUrl);
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_POST, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch2, CURLOPT_POSTFIELDS, json_encode($payload2));

$response2 = curl_exec($ch2);
$httpCode2 = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
curl_close($ch2);

echo "HTTP Code: $httpCode2\n";
echo "Response:\n";

if ($response2) {
    $decoded2 = json_decode($response2, true);
    echo json_encode($decoded2, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($decoded2['eResponse']['success']) && $decoded2['eResponse']['success']) {
        echo "\n✅ EJEMPLO 2 EXITOSO\n";
        if (isset($decoded2['eResponse']['data']) && is_array($decoded2['eResponse']['data'])) {
            foreach ($decoded2['eResponse']['data'] as $row) {
                echo "  - ID: {$row['cveconcepto']} | Acción: {$row['accion']} | Resultado: {$row['resultado']}\n";
            }
        }
    } else {
        echo "\n❌ EJEMPLO 2 FALLÓ\n";
    }
} else {
    echo "❌ Sin respuesta\n";
}

// EJEMPLO 3: Actualización masiva
echo "\n\n=== EJEMPLO 3: Actualización masiva (3 registros) ===\n";

$ejemplo3 = [
    ["cveconcepto" => 1, "descripcion" => "IMPUESTO PREDIAL", "ncorto" => "PREDIAL", "cvegrupo" => 1],
    ["cveconcepto" => 2, "descripcion" => "TRANSMISION PATRIMONIAL", "ncorto" => "TRANSM-PAT", "cvegrupo" => 1],
    ["cveconcepto" => 3, "descripcion" => "LICENCIAS Y PERMISOS", "ncorto" => "LICENCIAS", "cvegrupo" => 1]
];

$payload3 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_publicos_upd',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_datos',
                'valor' => json_encode($ejemplo3),
                'tipo' => 'string'
            ]
        ],
        'Tenant' => ''
    ]
];

$ch3 = curl_init($apiUrl);
curl_setopt($ch3, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch3, CURLOPT_POST, true);
curl_setopt($ch3, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch3, CURLOPT_POSTFIELDS, json_encode($payload3));

$response3 = curl_exec($ch3);
$httpCode3 = curl_getinfo($ch3, CURLINFO_HTTP_CODE);
curl_close($ch3);

echo "HTTP Code: $httpCode3\n";
echo "Response:\n";

if ($response3) {
    $decoded3 = json_decode($response3, true);
    echo json_encode($decoded3, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($decoded3['eResponse']['success']) && $decoded3['eResponse']['success']) {
        echo "\n✅ EJEMPLO 3 EXITOSO\n";
        if (isset($decoded3['eResponse']['data']) && is_array($decoded3['eResponse']['data'])) {
            foreach ($decoded3['eResponse']['data'] as $row) {
                echo "  - ID: {$row['cveconcepto']} | Acción: {$row['accion']}\n";
            }
        }
    } else {
        echo "\n❌ EJEMPLO 3 FALLÓ\n";
    }
} else {
    echo "❌ Sin respuesta\n";
}

echo "\n\n=== RESUMEN ===\n";
echo "✅ Si todos los ejemplos pasaron, el componente Vue debe funcionar correctamente\n";
echo "🔍 Formato de parámetros correcto: array con objetos {nombre, valor, tipo}\n";
?>
