<?php
/**
 * Probar recaudadora_actualiza_fechas vía API genérica
 * Test individual de un folio
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

// Test 1: Actualización individual de un folio
echo "========================================\n";
echo "TEST 1: Actualización individual\n";
echo "========================================\n\n";

$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_ACTUALIZA_FECHAS',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '123456789'],
            ['nombre' => 'p_folio', 'tipo' => 'integer', 'valor' => 1001],
            ['nombre' => 'p_anio_folio', 'tipo' => 'integer', 'valor' => 2023],
            ['nombre' => 'p_fecha_practica', 'tipo' => 'date', 'valor' => '2025-11-25'],
            ['nombre' => 'p_ejecutor', 'tipo' => 'integer', 'valor' => 1]
        ],
        'Tenant' => ''
    ]
];

echo "📤 Enviando request...\n";
echo "Folio: 1001 | Cuenta: 123456789 | Año: 2023\n";
echo "Fecha práctica: 2025-11-25\n\n";

$ch = curl_init($apiUrl);
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

echo "📥 Respuesta HTTP: $httpCode\n\n";

if ($response === false) {
    echo "❌ Error al ejecutar curl\n";
    exit(1);
}

$data = json_decode($response, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "❌ Error al decodificar JSON: " . json_last_error_msg() . "\n";
    echo "Respuesta raw:\n$response\n";
    exit(1);
}

echo "Respuesta:\n";
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

if (isset($data['eResponse'])) {
    $eResponse = $data['eResponse'];

    if ($eResponse['success']) {
        echo "✅ Operación exitosa\n";

        if (isset($eResponse['data']['result'][0])) {
            $result = $eResponse['data']['result'][0];
            echo "📊 Resultado:\n";
            echo "  - Aplicados: " . $result['aplicados'] . "\n";

            $errores = json_decode($result['errores'], true);
            if (empty($errores)) {
                echo "  - Errores: ninguno\n";
                echo "\n✅ ¡FOLIO ACTUALIZADO CORRECTAMENTE!\n";
            } else {
                echo "  - Errores: " . count($errores) . "\n";
                foreach ($errores as $err) {
                    echo "    * Folio {$err['folio']}: {$err['error']}\n";
                }
            }
        }
    } else {
        echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
    }
} else {
    echo "❌ Formato de respuesta inesperado\n";
}

echo "\n========================================\n\n";

// Test 2: Verificar que la fecha se actualizó en la BD
echo "TEST 2: Verificación en BD\n";
echo "========================================\n\n";

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->prepare("
        SELECT cvereq, cvecuenta, folioreq, axoreq, fecprac, cveejecut, fecentejec
        FROM catastro_gdl.reqdiftransmision
        WHERE cvecuenta::TEXT = '123456789' AND folioreq = 1001 AND axoreq = 2023
    ");
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        echo "✅ Folio encontrado en BD:\n";
        echo "  - cvereq: {$row['cvereq']}\n";
        echo "  - Cuenta: {$row['cvecuenta']}\n";
        echo "  - Folio: {$row['folioreq']}\n";
        echo "  - Año: {$row['axoreq']}\n";
        echo "  - Fecha práctica (fecprac): " . ($row['fecprac'] ?? 'NULL') . "\n";
        echo "  - Ejecutor (cveejecut): " . ($row['cveejecut'] ?? 'NULL') . "\n";
        echo "  - Fecha entrega ejecutor (fecentejec): " . ($row['fecentejec'] ?? 'NULL') . "\n";

        if ($row['fecprac'] == '2025-11-25') {
            echo "\n✅ ¡FECHA ACTUALIZADA CORRECTAMENTE!\n";
        } else {
            echo "\n⚠️ La fecha no coincide con la esperada\n";
        }
    } else {
        echo "❌ Folio no encontrado en BD\n";
    }

} catch (Exception $e) {
    echo "❌ Error conectando a BD: " . $e->getMessage() . "\n";
}
