<?php
// Script para probar la API de drecgolic

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API DrecgoLic ===\n\n";

// Ejemplos de Licencias
$ejemplos = [
    ['licencia' => '1', 'descripcion' => 'Licencia 1 - ALBARRAN, S.A .DE C.V. SUC. JUAN ALVAREZ'],
    ['licencia' => '5', 'descripcion' => 'Licencia 5 - LOPEZ BERMUDEZ ENRIQUE'],
    ['licencia' => '8', 'descripcion' => 'Licencia 8 - ROBLES ALVAREZ JUAN']
];

foreach ($ejemplos as $index => $ejemplo) {
    $num = $index + 1;
    $licencia = $ejemplo['licencia'];
    $descripcion = $ejemplo['descripcion'];

    echo "=======================================================\n";
    echo "Prueba $num: $descripcion\n";
    echo "=======================================================\n\n";

    $payload = [
        'eRequest' => [
            'Operacion' => 'recaudadora_drecgolic',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_licencia', 'tipo' => 'string', 'valor' => $licencia]
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
                echo "Total de registros: " . count($result) . "\n\n";
                $row = $result[0];
                echo "Información de la Licencia:\n";
                echo "  ID Licencia: {$row['id_licencia']}\n";
                echo "  Licencia: {$row['licencia']}\n";
                echo "  Propietario: {$row['propietario']}\n";
                echo "  RFC: {$row['rfc']}\n";
                echo "  Domicilio: {$row['domicilio']}\n";
                echo "  Giro: {$row['id_giro']}\n";
                echo "  Zona: {$row['zona']} / Subzona: {$row['subzona']}\n";
                echo "  CVE Cuenta: {$row['cvecuenta']}\n";
                echo "  Fecha Otorgamiento: {$row['fecha_otorgamiento']}\n";
                echo "  Coordenadas: {$row['coordenadas']}\n\n";
            } else {
                echo "No se encontró información para esta licencia\n";
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
echo "✓ 3 Ejemplos para probar en la interfaz Vue:\n\n";
foreach ($ejemplos as $i => $ej) {
    echo ($i + 1) . ". Licencia: {$ej['licencia']}\n";
    echo "   {$ej['descripcion']}\n\n";
}
echo "\nPrimero debes ejecutar: php temp/deploy_drecgolic.php\n";
echo "para desplegar el stored procedure en la base de datos.\n";
