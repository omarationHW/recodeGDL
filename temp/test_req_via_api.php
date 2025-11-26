<?php
// Probar SP recaudadora_req via API
echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║         PRUEBA DE recaudadora_req VIA API                 ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

$api_url = "http://127.0.0.1:8000/api/generic";

// Prueba 1: Buscar todos los requerimientos del 2025
echo "--- PRUEBA 1: Buscar requerimientos del 2025 ---\n";
$payload1 = [
    'operation' => 'RECAUDADORA_REQ',
    'baseDb' => 'multas_reglamentos',
    'parameters' => [
        ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => ''],
        ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 2025]
    ]
];

$ch = curl_init($api_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload1));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response1 = curl_exec($ch);
$http_code1 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Status: $http_code1\n";

if ($response1) {
    $data1 = json_decode($response1, true);

    if (isset($data1['success']) && $data1['success']) {
        echo "✅ Éxito\n";
        $rows = $data1['data']['rows'] ?? $data1['result'] ?? [];
        echo "Total de registros: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "\nResultados:\n";
            foreach ($rows as $row) {
                echo sprintf(
                    "  CVE: %-5s | Cuenta: %-10s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                    $row['cvereq'] ?? '',
                    $row['cvecuenta'] ?? '',
                    $row['folioreq'] ?? '',
                    $row['axoreq'] ?? '',
                    $row['total'] ?? 0
                );
            }
        }
    } else {
        echo "❌ Error en la respuesta\n";
        echo json_encode($data1, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
    }
} else {
    echo "❌ Error de cURL: " . curl_error($ch) . "\n";
}

// Prueba 2: Buscar por cuenta específica
echo "\n--- PRUEBA 2: Buscar por cuenta 12345 ---\n";
$payload2 = [
    'operation' => 'RECAUDADORA_REQ',
    'baseDb' => 'multas_reglamentos',
    'parameters' => [
        ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '12345'],
        ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 0]
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload2));
$response2 = curl_exec($ch);
$http_code2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Status: $http_code2\n";

if ($response2) {
    $data2 = json_decode($response2, true);

    if (isset($data2['success']) && $data2['success']) {
        echo "✅ Éxito\n";
        $rows = $data2['data']['rows'] ?? $data2['result'] ?? [];
        echo "Total de registros: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "\nResultados:\n";
            foreach ($rows as $row) {
                echo sprintf(
                    "  CVE: %-5s | Cuenta: %-10s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                    $row['cvereq'] ?? '',
                    $row['cvecuenta'] ?? '',
                    $row['folioreq'] ?? '',
                    $row['axoreq'] ?? '',
                    $row['total'] ?? 0
                );
            }
        }
    } else {
        echo "❌ Error en la respuesta\n";
        echo json_encode($data2, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
    }
} else {
    echo "❌ Error de cURL: " . curl_error($ch) . "\n";
}

curl_close($ch);

echo "\n✅ Pruebas via API completadas\n";
echo "\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║                   INSTRUCCIONES                           ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";
echo "Ahora puedes probar el formulario Req.vue en el navegador:\n";
echo "1. Abre: http://localhost:3001\n";
echo "2. Navega a: Multas y Reglamentos > Requerimiento\n";
echo "3. Ingresa:\n";
echo "   - Cuenta: (vacío para todos, o 12345 para específico)\n";
echo "   - Año: 2025\n";
echo "4. Haz clic en 'Buscar'\n";
echo "5. Deberías ver la tabla con los resultados\n";
echo "\n";
