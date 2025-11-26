<?php
/**
 * Probar recaudadora_parse_file vía API genérica
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

// Leer contenido del archivo de ejemplo
$fileContent = file_get_contents(__DIR__ . '/ejemplo_folios.txt');

$payload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_PARSE_FILE',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            [
                'nombre' => 'p_file_content',
                'tipo' => 'string',
                'valor' => $fileContent
            ]
        ],
        'Tenant' => ''
    ]
];

echo "📤 Enviando request a API...\n";
echo "URL: $apiUrl\n";
echo "Operación: RECAUDADORA_PARSE_FILE\n";
echo "Contenido del archivo:\n";
echo $fileContent . "\n\n";

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

echo "Respuesta completa:\n";
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

if (isset($data['eResponse'])) {
    $eResponse = $data['eResponse'];

    if ($eResponse['success']) {
        echo "✅ Operación exitosa\n";

        if (isset($eResponse['data']['result'])) {
            $folios = $eResponse['data']['result'];
            echo "📊 Folios parseados: " . count($folios) . "\n\n";

            if (count($folios) > 0) {
                echo "Primeros 3 folios:\n";
                foreach (array_slice($folios, 0, 3) as $idx => $folio) {
                    echo sprintf(
                        "  %d. Cuenta: %s | Folio: %d | Año: %d | Propietario: %s\n",
                        $idx + 1,
                        $folio['clave_cuenta'],
                        $folio['folio'],
                        $folio['anio_folio'],
                        $folio['propietario']
                    );
                }
            }
        } else {
            echo "⚠️ No se encontró 'result' en la respuesta\n";
        }
    } else {
        echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
    }
} else {
    echo "❌ Formato de respuesta inesperado\n";
}
