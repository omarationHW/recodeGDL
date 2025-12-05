<?php
/**
 * Script para probar la API de Empresas usando el endpoint real
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

$api_url = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API EMPRESAS ===\n\n";

function callAPI($url, $operacion, $base, $parametros) {
    $eRequest = [
        'Operacion' => $operacion,
        'Base' => $base,
        'Parametros' => $parametros,
        'Tenant' => ''
    ];

    $data = ['eRequest' => $eRequest];

    echo "📤 REQUEST:\n";
    echo json_encode($data, JSON_PRETTY_PRINT) . "\n\n";

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($response === false) {
        return ['error' => 'Error al conectar con la API'];
    }

    $decoded = json_decode($response, true);

    echo "📥 RESPONSE (HTTP $http_code):\n";
    echo json_encode($decoded, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    return $decoded;
}

// PRUEBA: Buscar todos los registros
echo "=== PRUEBA: Buscar todos (primeros 5) ===\n\n";

$params = [
    ['nombre' => 'q', 'tipo' => 'string', 'valor' => ''],
    ['nombre' => 'offset', 'tipo' => 'integer', 'valor' => 0],
    ['nombre' => 'limit', 'tipo' => 'integer', 'valor' => 5]
];

$response = callAPI($api_url, 'recaudadora_empresas', 'multas_reglamentos', $params);

if (isset($response['eResponse'])) {
    $eResponse = $response['eResponse'];

    if ($eResponse['success']) {
        echo "✅ ÉXITO!\n";
        $data = $eResponse['data'];
        echo "📊 Total de registros: " . (count($data) > 0 ? $data[0]['total_count'] : 0) . "\n";
        echo "📄 Registros en esta página: " . count($data) . "\n\n";

        if (count($data) > 0) {
            echo "Empresas encontradas:\n";
            foreach ($data as $i => $row) {
                echo ($i + 1) . ". {$row['empresa']} - RFC: {$row['rfc']}\n";
            }
        }
    } else {
        echo "❌ ERROR: {$eResponse['message']}\n";
    }
} else {
    echo "❌ Respuesta inválida de la API\n";
}

echo "\n=== FIN DE LA PRUEBA ===\n";
?>
