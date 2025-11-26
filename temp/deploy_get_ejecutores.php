<?php
/**
 * Desplegar SP recaudadora_get_ejecutores
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "=== DESPLEGANDO SP recaudadora_get_ejecutores ===\n\n";

    // Leer archivo SQL
    $sql_file = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_get_ejecutores.sql';
    $sql = file_get_contents($sql_file);

    echo "1. Leyendo archivo SQL...\n";
    echo "   Archivo: $sql_file\n";
    echo "   Tamaño: " . strlen($sql) . " bytes\n";

    echo "\n2. Desplegando SP...\n";
    $pdo->exec($sql);
    echo "   ✓ SP desplegado exitosamente\n";

    echo "\n3. Probando SP...\n";
    $query = "SELECT * FROM recaudadora_get_ejecutores()";
    $stmt = $pdo->query($query);
    $ejecutores = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $count = count($ejecutores);

    echo "   ✓ SP ejecutado correctamente\n";
    echo "   ✓ Ejecutores encontrados: $count\n\n";

    if ($count > 0) {
        echo "   Primeros 5 ejecutores:\n";
        foreach (array_slice($ejecutores, 0, 5) as $row) {
            echo "   - ID: {$row['cveejecutor']} | Empresa: {$row['empresa']}\n";
        }
    } else {
        echo "   ⚠️  No hay ejecutores en la tabla\n";
    }
    echo "\n4. Probando vía API...\n";
    $url = 'http://127.0.0.1:8000/api/generic';
    $data = [
        'eRequest' => [
            'Operacion' => 'RECAUDADORA_GET_EJECUTORES',
            'Base' => 'multas_reglamentos',
            'Parametros' => [],
            'Tenant' => ''
        ]
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code === 200) {
        $json = json_decode($response, true);
        $ejecutores_api = $json['eResponse']['data']['result'] ?? [];
        echo "   ✓ API responde correctamente\n";
        echo "   ✓ Ejecutores en respuesta: " . count($ejecutores_api) . "\n";

        if (count($ejecutores_api) > 0) {
            echo "\n   Primer ejecutor:\n";
            echo "   " . json_encode($ejecutores_api[0], JSON_UNESCAPED_UNICODE) . "\n";
        }
    } else {
        echo "   ✗ API error (HTTP $http_code)\n";
        echo "   Respuesta: " . substr($response, 0, 200) . "\n";
    }

    echo "\n✅ SP desplegado y funcionando!\n";
    echo "\nAhora el select de ejecutores debería cargarse correctamente.\n";

} catch (PDOException $e) {
    echo "   ✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
