<?php
/**
 * Test para ver la estructura de respuesta de la API
 */

$url = 'http://127.0.0.1:8000/api/generic';

$data = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_BLOQUEO_MULTA',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'valor' => '', 'tipo' => 'string'],
            ['nombre' => 'p_ejercicio', 'valor' => 2024, 'tipo' => 'int'],
            ['nombre' => 'p_offset', 'valor' => 0, 'tipo' => 'int'],
            ['nombre' => 'p_limit', 'valor' => 10, 'tipo' => 'int']
        ],
        'Tenant' => ''
    ]
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "=== RESPUESTA DE LA API ===\n";
echo "HTTP Code: $http_code\n\n";

if ($response === false) {
    echo "ERROR: No se pudo conectar a la API\n";
    exit(1);
}

$json = json_decode($response, true);

echo "=== ESTRUCTURA COMPLETA ===\n";
echo json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

echo "=== ANÁLISIS DE LA ESTRUCTURA ===\n";
if (isset($json['result'])) {
    echo "✓ Tiene campo 'result'\n";
    if (is_array($json['result'])) {
        echo "  - Es un array con " . count($json['result']) . " elementos\n";
        if (!empty($json['result'])) {
            echo "  - Primera fila:\n";
            echo json_encode($json['result'][0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
        }
    }
}

if (isset($json['data'])) {
    echo "✓ Tiene campo 'data'\n";
    if (is_array($json['data'])) {
        echo "  - Es un array con " . count($json['data']) . " elementos\n";
        if (!empty($json['data'])) {
            echo "  - Primera fila:\n";
            echo json_encode($json['data'][0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
        }
    }
}

if (isset($json['count'])) {
    echo "✓ Tiene campo 'count': {$json['count']}\n";
}

if (isset($json['total'])) {
    echo "✓ Tiene campo 'total': {$json['total']}\n";
}

if (is_array($json)) {
    echo "\n=== CAMPOS DE NIVEL SUPERIOR ===\n";
    foreach (array_keys($json) as $key) {
        $type = gettype($json[$key]);
        $count = is_array($json[$key]) ? count($json[$key]) : '';
        echo "- $key ($type) $count\n";
    }
} else {
    echo "\n⚠️ La respuesta no es un array válido\n";
}
