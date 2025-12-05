<?php
/**
 * Script para simular la llamada del frontend a la API
 */

try {
    echo "=== SIMULANDO LLAMADA DE LA API ===\n\n";

    // Simular la petición del frontend
    $url = "http://127.0.0.1:8000/api/generic/execute";

    $payload = [
        'sp_name' => 'RECAUDADORA_PAGOS_ESPE',
        'base_db' => 'multas_reglamentos',
        'params' => [
            ['name' => 'clave_cuenta', 'type' => 'C', 'value' => '281048'],
            ['name' => 'ejercicio', 'type' => 'I', 'value' => 0]
        ]
    ];

    echo "1. Datos enviados:\n";
    echo json_encode($payload, JSON_PRETTY_PRINT) . "\n\n";

    // Hacer la petición
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

    echo "2. Código HTTP: $httpCode\n\n";

    if ($response) {
        $data = json_decode($response, true);

        if (isset($data['rows'])) {
            $count = count($data['rows']);
            echo "3. Registros recibidos: $count\n\n";

            if ($count > 0 && $count <= 3) {
                echo "   Primeros registros:\n";
                foreach ($data['rows'] as $i => $row) {
                    echo "   - Cuenta: {$row['cvecuenta']}, CVE Aut: {$row['cveaut']}\n";
                }
            } elseif ($count > 3) {
                echo "   Mostrando primeros 3:\n";
                for ($i = 0; $i < 3; $i++) {
                    $row = $data['rows'][$i];
                    echo "   - Cuenta: {$row['cvecuenta']}, CVE Aut: {$row['cveaut']}\n";
                }
            }

            echo "\n=== DIAGNÓSTICO ===\n";
            if ($count == 3728) {
                echo "❌ PROBLEMA: La API está retornando TODOS los registros (3728)\n";
                echo "   El problema está en cómo la API procesa los parámetros\n";
            } elseif ($count == 10) {
                echo "✓ La API está funcionando correctamente\n";
            } else {
                echo "⚠ Resultado inesperado: $count registros\n";
            }
        } elseif (isset($data['error'])) {
            echo "❌ ERROR de la API:\n";
            echo "   " . $data['error'] . "\n";
            if (isset($data['message'])) {
                echo "   Mensaje: " . $data['message'] . "\n";
            }
        } else {
            echo "❌ Respuesta inesperada:\n";
            echo json_encode($data, JSON_PRETTY_PRINT) . "\n";
        }
    } else {
        echo "❌ No se recibió respuesta del servidor\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
