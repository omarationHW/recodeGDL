<?php
/**
 * Script para probar el SP recaudadora_bloqctasreqfrm a través de la API
 */

$baseUrl = 'http://127.0.0.1:8000/api/generic';

// Obtener una cuenta de ejemplo que tenga bloqueos
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = "SELECT DISTINCT cvecuenta FROM catastro_gdl.norequeribles LIMIT 5";
    $stmt = $pdo->query($sql);
    $cuentas = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($cuentas)) {
        echo "❌ No se encontraron cuentas con bloqueos\n";
        exit(1);
    }

    $cuenta = $cuentas[0];
    echo "=== Probando API Genérica - bloqctasreqfrm ===\n";
    echo "URL: $baseUrl\n";
    echo "SP: recaudadora_bloqctasreqfrm\n";
    echo "Cuenta: $cuenta\n";
    echo str_repeat("-", 80) . "\n\n";

    $payload = [
        'eRequest' => [
            'Operacion' => 'recaudadora_bloqctasreqfrm',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'public',
            'Parametros' => [
                [
                    'nombre' => 'p_clave_cuenta',
                    'valor' => $cuenta,
                    'tipo' => 'string'
                ]
            ]
        ]
    ];

    $ch = curl_init($baseUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    echo "HTTP Code: $httpCode\n";
    echo "Respuesta:\n";
    echo str_repeat("-", 80) . "\n";

    if ($response) {
        $data = json_decode($response, true);
        echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

        if (isset($data['eResponse']['data']['result'])) {
            echo "\n✅ Total de registros: " . count($data['eResponse']['data']['result']) . "\n";
            if (count($data['eResponse']['data']['result']) > 0) {
                echo "\nPrimer registro:\n";
                echo json_encode($data['eResponse']['data']['result'][0], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
            }
        }
    } else {
        echo "❌ No se recibió respuesta del servidor\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "Probando con cuenta sin bloqueos (99999):\n\n";

    $payload['eRequest']['Parametros'][0]['valor'] = '99999';

    $ch = curl_init($baseUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    echo "HTTP Code: $httpCode\n";
    echo "Respuesta:\n";
    echo str_repeat("-", 80) . "\n";

    if ($response) {
        $data = json_decode($response, true);
        echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

        if (isset($data['eResponse']['data']['result'])) {
            echo "\n✅ Total de registros: " . count($data['eResponse']['data']['result']) . " (esperado: 0)\n";
        }
    } else {
        echo "❌ No se recibió respuesta del servidor\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de BD: " . $e->getMessage() . "\n";
}
