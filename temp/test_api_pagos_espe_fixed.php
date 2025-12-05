<?php
/**
 * Script para probar la API con el formato correcto
 */

try {
    echo "=== PROBANDO API CON FORMATO CORRECTO ===\n\n";

    $url = "http://127.0.0.1:8000/api/generic";

    // Formato correcto según GenericController
    $payload = [
        'eRequest' => [
            'Operacion' => 'RECAUDADORA_PAGOS_ESPE',
            'Base' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '281048'],
                ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => null]
            ]
        ]
    ];

    echo "1. Datos enviados:\n";
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

    echo "2. Código HTTP: $httpCode\n\n";

    if ($response) {
        $data = json_decode($response, true);

        if (isset($data['eResponse'])) {
            $eResponse = $data['eResponse'];

            if (isset($eResponse['success']) && $eResponse['success']) {
                if (isset($eResponse['data']['rows'])) {
                    $rows = $eResponse['data']['rows'];
                    $count = count($rows);

                    echo "3. ✅ ÉXITO - Registros recibidos: $count\n\n";

                    if ($count <= 3) {
                        echo "   Registros:\n";
                        foreach ($rows as $i => $row) {
                            echo "   " . ($i + 1) . ". Cuenta: {$row['cvecuenta']}, CVE Aut: {$row['cveaut']}, Estado: {$row['estado']}\n";
                        }
                    } else {
                        echo "   Primeros 3 registros:\n";
                        for ($i = 0; $i < 3; $i++) {
                            $row = $rows[$i];
                            echo "   " . ($i + 1) . ". Cuenta: {$row['cvecuenta']}, CVE Aut: {$row['cveaut']}, Estado: {$row['estado']}\n";
                        }
                    }

                    echo "\n=== RESULTADO ===\n";
                    if ($count == 10) {
                        echo "✅ PERFECTO: El filtro funciona correctamente (10 registros para cuenta 281048)\n";
                    } elseif ($count == 3728) {
                        echo "❌ PROBLEMA: Sigue retornando todos los registros\n";
                    } else {
                        echo "⚠ Resultado: $count registros\n";
                    }
                }
            } else {
                echo "❌ ERROR de la API:\n";
                echo "   " . ($eResponse['message'] ?? 'Error desconocido') . "\n";
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
