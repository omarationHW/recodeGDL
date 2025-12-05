<?php
// Script para probar la API de dderechosLic

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API dderechosLic ===\n\n";

// Ejemplos de licencias conocidas con derechos pendientes
$ejemplos = [
    ['licencia' => 14862, 'nombre' => 'DURAN HAMPSHIRE CARLOS - Bar anexo a restaurant'],
    ['licencia' => 15031, 'nombre' => 'AGUILERA PEREZ RAFAEL - Salón de conferencias'],
    ['licencia' => 16285, 'nombre' => 'CASTRO ZATARAY NELSON - Cabaret']
];

foreach ($ejemplos as $index => $ejemplo) {
    $num = $index + 1;
    $licencia = $ejemplo['licencia'];
    $nombre = $ejemplo['nombre'];

    echo "=======================================================\n";
    echo "Prueba $num: Licencia $licencia\n";
    echo "$nombre\n";
    echo "=======================================================\n\n";

    $payload = [
        'eRequest' => [
            'Operacion' => 'recaudadora_dderechoslic',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_licencia', 'tipo' => 'int', 'valor' => $licencia]
            ],
            'Tenant' => ''
        ]
    ];

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

    if ($httpCode == 200) {
        $data = json_decode($response, true);
        if ($data['eResponse']['success']) {
            echo "✓ Respuesta exitosa\n\n";
            $result = $data['eResponse']['data']['result'];

            if (count($result) > 0) {
                $first = $result[0];
                echo "Información de la Licencia:\n";
                echo "  Licencia: {$first['licencia']}\n";
                echo "  Propietario: " . trim($first['propietario']) . "\n";
                echo "  Actividad: " . trim($first['actividad']) . "\n";
                echo "  Domicilio: " . trim($first['domicilio']) . "\n";
                echo "  Total Licencia: $" . number_format($first['total_licencia'], 2) . "\n";
                echo "\n";

                echo "Detalle de Derechos por Año:\n";
                $limit = min(5, count($result));
                for ($i = 0; $i < $limit; $i++) {
                    $row = $result[$i];
                    echo "  Año {$row['axo']}: ";
                    echo "Derechos=\$" . number_format($row['derechos'], 2) . ", ";
                    echo "Recargos=\$" . number_format($row['recargos'], 2) . ", ";
                    echo "Multas=\$" . number_format($row['multas'], 2) . ", ";
                    echo "Pagado={$row['pagado']}\n";
                }

                if (count($result) > 5) {
                    echo "  ... y " . (count($result) - 5) . " años más\n";
                }
            } else {
                echo "No se encontraron derechos para esta licencia\n";
            }
        } else {
            echo "✗ Error: " . $data['eResponse']['message'] . "\n";
        }
    } else {
        echo "✗ Error HTTP $httpCode\n";
        echo "Respuesta: $response\n";
    }

    echo "\n\n";
}

curl_close($ch);

echo "=== FIN DE PRUEBAS ===\n\n";
echo "Puedes usar cualquiera de estas licencias en la interfaz Vue:\n";
foreach ($ejemplos as $i => $ej) {
    echo ($i + 1) . ". Licencia {$ej['licencia']} - {$ej['nombre']}\n";
}
echo "\nNota: Estos son números de licencia reales con derechos pendientes.\n";
