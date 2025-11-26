<?php
// Probar SP recaudadora_req
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("❌ Error de conexión\n");
}

echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║           PRUEBA DE SP: recaudadora_req                   ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

// Prueba 1: Consultar todos los requerimientos (sin filtros)
echo "--- PRUEBA 1: Consultar todos los requerimientos ---\n";
$result1 = pg_query($conn, "SELECT * FROM recaudadora_req(NULL, NULL)");

if ($result1) {
    $count = pg_num_rows($result1);
    echo "✅ Total de registros: $count\n";

    if ($count > 0) {
        echo "\nPrimeros 3 registros:\n";
        $i = 0;
        while ($row = pg_fetch_assoc($result1) && $i < 3) {
            echo sprintf(
                "  CVE: %-5s | Cuenta: %-10s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq'],
                $row['axoreq'],
                $row['total']
            );
            $i++;
        }
    }
} else {
    echo "❌ Error: " . pg_last_error($conn) . "\n";
}

// Prueba 2: Consultar por ejercicio 2025
echo "\n--- PRUEBA 2: Consultar por ejercicio 2025 ---\n";
$result2 = pg_query($conn, "SELECT * FROM recaudadora_req(NULL, 2025)");

if ($result2) {
    $count = pg_num_rows($result2);
    echo "✅ Registros del 2025: $count\n";

    if ($count > 0) {
        while ($row = pg_fetch_assoc($result2)) {
            echo sprintf(
                "  CVE: %-5s | Cuenta: %-10s | Folio: %-8s | Año: %s | Total: $%.2f | Vigencia: %s\n",
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq'],
                $row['axoreq'],
                $row['total'],
                $row['vigencia']
            );
        }
    }
} else {
    echo "❌ Error: " . pg_last_error($conn) . "\n";
}

// Prueba 3: Consultar por cuenta específica
echo "\n--- PRUEBA 3: Consultar por cuenta 12345 ---\n";
$result3 = pg_query($conn, "SELECT * FROM recaudadora_req('12345', NULL)");

if ($result3) {
    $count = pg_num_rows($result3);
    echo "✅ Registros con cuenta 12345: $count\n";

    if ($count > 0) {
        while ($row = pg_fetch_assoc($result3)) {
            echo sprintf(
                "  CVE: %-5s | Cuenta: %-10s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq'],
                $row['axoreq'],
                $row['total']
            );
        }
    } else {
        echo "  (No hay registros con esa cuenta)\n";
    }
} else {
    echo "❌ Error: " . pg_last_error($conn) . "\n";
}

// Prueba 4: Probar via API como lo hace el frontend
echo "\n\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║              PRUEBA VIA API (como frontend)               ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

$api_url = "http://127.0.0.1:8000/api/execute";
$payload = [
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
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

echo "🌐 Llamando a la API...\n";
echo "URL: $api_url\n";
echo "Payload: " . json_encode($payload, JSON_PRETTY_PRINT) . "\n\n";

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Status: $http_code\n";

if ($response) {
    $data = json_decode($response, true);
    echo "Respuesta:\n";
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

    if (isset($data['success']) && $data['success']) {
        echo "\n✅ API funcionando correctamente\n";
    } else {
        echo "\n⚠ API respondió pero con error\n";
    }
} else {
    echo "❌ Error de cURL: " . curl_error($ch) . "\n";
}

curl_close($ch);

pg_close($conn);

echo "\n✅ Pruebas completadas\n";
