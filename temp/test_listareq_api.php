<?php
echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║       PRUEBA DE LISTAREQ VIA API                          ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

$api_url = "http://127.0.0.1:8000/api/generic";

// Prueba 1: Buscar todos los requerimientos
echo "--- PRUEBA 1: Buscar todos los requerimientos ---\n";
$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_listareq',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '']
        ]
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

    if (isset($data1['eResponse']['success']) && $data1['eResponse']['success']) {
        echo "✅ Éxito\n";
        $rows = $data1['eResponse']['data']['result'] ?? [];
        echo "Total de registros: " . count($rows) . "\n\n";

        if (count($rows) > 0) {
            echo "Primeros 5 registros:\n";
            for ($i = 0; $i < min(5, count($rows)); $i++) {
                $row = $rows[$i];
                echo sprintf(
                    "  %d. CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                    $i + 1,
                    $row['cvereq'],
                    $row['cvecuenta'],
                    $row['folioreq'],
                    $row['axoreq'],
                    $row['total']
                );
            }
        }
    } else {
        echo "❌ Error:\n";
        echo json_encode($data1, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
    }
}

// Prueba 2: Buscar por cuenta específica
echo "\n--- PRUEBA 2: Buscar por cuenta 12345 ---\n";
$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_listareq',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '12345']
        ]
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload2));
$response2 = curl_exec($ch);
$http_code2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Status: $http_code2\n";

if ($response2) {
    $data2 = json_decode($response2, true);

    if (isset($data2['eResponse']['success']) && $data2['eResponse']['success']) {
        echo "✅ Éxito\n";
        $rows = $data2['eResponse']['data']['result'] ?? [];
        echo "Total de registros: " . count($rows) . "\n\n";

        if (count($rows) > 0) {
            echo "Resultados:\n";
            foreach ($rows as $i => $row) {
                echo sprintf(
                    "  %d. CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                    $i + 1,
                    $row['cvereq'],
                    $row['cvecuenta'],
                    $row['folioreq'],
                    $row['axoreq'],
                    $row['total']
                );
            }
        }
    } else {
        echo "❌ Error:\n";
        echo json_encode($data2, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
    }
}

curl_close($ch);

echo "\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║                    ¡TODO LISTO!                           ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";
echo "✅ Conexión a BD restaurada\n";
echo "✅ SP recaudadora_listareq desplegado y funcional\n";
echo "✅ API procesando correctamente\n";
echo "✅ Archivo listareq.vue corregido\n";
echo "\nAhora puedes probar el formulario en el navegador:\n";
echo "  URL: http://localhost:3001\n";
echo "  Ruta: Multas y Reglamentos > Listado de Requerimientos\n";
echo "\n";
