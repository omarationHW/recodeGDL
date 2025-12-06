<?php
/**
 * Script para probar la respuesta de la API genérica
 * simulando la llamada desde el frontend
 */

$url = "http://localhost:8000/api/generic";

$payload = [
    'eRequest' => [
        'Operacion' => 'sp_consulta_general_buscar',
        'Base' => 'mercados',
        'Parametros' => [
            ['Nombre' => 'p_oficina', 'Valor' => 1],
            ['Nombre' => 'p_num_mercado', 'Valor' => 2],
            ['Nombre' => 'p_categoria', 'Valor' => 1],
            ['Nombre' => 'p_seccion', 'Valor' => 'SS'],
            ['Nombre' => 'p_local', 'Valor' => 1],
            ['Nombre' => 'p_letra_local', 'Valor' => 'A'],
            ['Nombre' => 'p_bloque', 'Valor' => null]
        ]
    ]
];

echo "\n=== TEST API CONSULTA GENERAL ===\n\n";
echo "URL: $url\n";
echo "Payload:\n";
echo json_encode($payload, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init($url);
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

echo "HTTP Code: $httpCode\n";
echo "Response:\n";
echo str_repeat("-", 80) . "\n";

if ($response) {
    $data = json_decode($response, true);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "ANÁLISIS DE LA RESPUESTA:\n";
    echo str_repeat("=", 80) . "\n\n";

    if (isset($data['success'])) {
        echo "✅ Tiene campo 'success': " . ($data['success'] ? 'true' : 'false') . "\n";
    } else {
        echo "❌ NO tiene campo 'success'\n";
    }

    if (isset($data['data'])) {
        echo "✅ Tiene campo 'data'\n";
        if (is_array($data['data'])) {
            echo "   - Es un array con " . count($data['data']) . " elementos\n";
        }
    } else {
        echo "❌ NO tiene campo 'data'\n";
    }

    if (isset($data['eResponse'])) {
        echo "⚠️  Tiene estructura 'eResponse' (formato antiguo)\n";
        if (isset($data['eResponse']['success'])) {
            echo "   - eResponse.success: " . ($data['eResponse']['success'] ? 'true' : 'false') . "\n";
        }
        if (isset($data['eResponse']['data'])) {
            echo "   - eResponse.data existe\n";
            if (isset($data['eResponse']['data']['result'])) {
                echo "   - eResponse.data.result con " . count($data['eResponse']['data']['result']) . " elementos\n";
            }
        }
    }

} else {
    echo "❌ No se obtuvo respuesta\n";
}

echo "\n";
