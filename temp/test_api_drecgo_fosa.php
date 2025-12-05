<?php
// Script para probar la API de drecgo_fosa

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API DrecgoFosa ===\n\n";

// Ejemplos de IDs de fosa
$ejemplos = [
    ['id' => 2, 'nombre' => 'ID 2 - ARTURO GONZALEZ RAMIREZ - Cementerio Guadalajara'],
    ['id' => 7, 'nombre' => 'ID 7 - MANUEL LEE - Cementerio Guadalajara'],
    ['id' => 12, 'nombre' => 'ID 12 - VICENTE GONZALEZ DE LA MORA - Cementerio Guadalajara']
];

foreach ($ejemplos as $index => $ejemplo) {
    $num = $index + 1;
    $id = $ejemplo['id'];
    $nombre = $ejemplo['nombre'];

    echo "=======================================================\n";
    echo "Prueba $num: $nombre\n";
    echo "=======================================================\n\n";

    $payload = [
        'eRequest' => [
            'Operacion' => 'recaudadora_drecgo_fosa',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_folio', 'tipo' => 'int', 'valor' => $id]
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
                $row = $result[0];
                echo "Información de la Fosa:\n";
                echo "  ID Control: {$row['id_control']}\n";
                echo "  Cementerio: {$row['cementerio']}\n";
                echo "  Clase: {$row['clase']}\n";
                echo "  Sección: {$row['seccion']}\n";
                echo "  Línea: {$row['linea']}\n";
                echo "  Fosa: {$row['fosa']}\n";
                echo "  Titular: {$row['nombre_titular']}\n";
                echo "  Años: {$row['anio_minimo']} - {$row['anio_maximo']}\n\n";
            } else {
                echo "No se encontró información para este ID\n";
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
    echo ($i + 1) . ". Folio (ID): {$ej['id']}\n";
    echo "   {$ej['nombre']}\n\n";
}
echo "\nPrimero debes ejecutar: php temp/deploy_drecgo_fosa.php\n";
echo "para desplegar el stored procedure en la base de datos.\n";
