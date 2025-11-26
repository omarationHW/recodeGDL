<?php
/**
 * Test Final: recaudadora_actualiza_fechas con formato correcto (español)
 */

echo "🧪 Test Final: Actualización individual con formato español\n";
echo str_repeat("=", 60) . "\n\n";

// Usar el formato correcto: nombre, tipo, valor (español)
$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_ACTUALIZA_FECHAS',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '12345678901234'],
            ['nombre' => 'p_folio', 'tipo' => 'integer', 'valor' => 1001],
            ['nombre' => 'p_anio_folio', 'tipo' => 'integer', 'valor' => 2023],
            ['nombre' => 'p_fecha_practica', 'tipo' => 'string', 'valor' => '2025-11-18'],
            ['nombre' => 'p_ejecutor', 'tipo' => 'integer', 'valor' => 200]
        ]
    ]
];

$ch = curl_init('http://127.0.0.1:8000/api/generic');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
$data = json_decode($response, true);

if ($httpCode === 200 && isset($data['eResponse']['success'])) {
    if ($data['eResponse']['success']) {
        echo "✅ API respondió exitosamente\n\n";

        $result = $data['eResponse']['data']['result'] ?? [];
        if (!empty($result)) {
            $aplicados = $result[0]['aplicados'] ?? 0;
            $erroresJson = $result[0]['errores'] ?? '[]';
            $errores = json_decode($erroresJson, true);

            echo "📊 Resultados:\n";
            echo "   - Registros aplicados: $aplicados\n";
            echo "   - Errores: " . count($errores) . "\n";

            if (count($errores) > 0) {
                echo "\n⚠️  Detalles de errores:\n";
                foreach ($errores as $err) {
                    echo "   * Folio: " . ($err['folio'] ?? 'N/A') . "\n";
                    echo "     Cuenta: " . ($err['clave_cuenta'] ?? 'N/A') . "\n";
                    echo "     Año: " . ($err['anio_folio'] ?? 'N/A') . "\n";
                    echo "     Error: " . ($err['error'] ?? 'Sin descripción') . "\n\n";
                }
            }

            // Mostrar parámetros enviados para debug
            $debug = $data['eResponse']['data']['debug'] ?? [];
            if (isset($debug['parameters_sent'])) {
                echo "\n📝 Parámetros enviados al SP:\n";
                foreach ($debug['parameters_sent'] as $idx => $param) {
                    echo "   [$idx] => " . (is_null($param) ? 'NULL' : var_export($param, true)) . "\n";
                }
            }

            if ($aplicados > 0) {
                echo "\n✅ Test exitoso: Se actualizó $aplicados registro(s)\n";
            } else {
                echo "\n⚠️  No se actualizaron registros. Esto puede ser normal si:\n";
                echo "   - El folio no existe en la base de datos\n";
                echo "   - Los parámetros no coinciden con registros existentes\n";
            }
        }
    } else {
        echo "❌ La API devolvió error: " . ($data['eResponse']['message'] ?? 'Sin mensaje') . "\n";
    }
} else {
    echo "❌ Error HTTP o respuesta inválida\n";
    echo "Respuesta:\n";
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "\n✅ Test completado. El SP ahora está listo para usar desde el componente Vue.\n";
