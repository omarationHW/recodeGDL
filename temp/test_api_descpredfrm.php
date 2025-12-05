<?php
// Script para probar la API de descpredfrm

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API DescPredFrm ===\n\n";

// Ejemplos de CVE Cuentas con descuentos
$ejemplos = [
    ['cuenta' => '58', 'nombre' => 'CVE Cuenta 58 - 6 descuentos vigentes (Mayores 60 años - 50%)'],
    ['cuenta' => '60', 'nombre' => 'CVE Cuenta 60 - 11 descuentos (3a edad 75 años - 60%)'],
    ['cuenta' => '70', 'nombre' => 'CVE Cuenta 70 - 4 descuentos vigentes']
];

foreach ($ejemplos as $index => $ejemplo) {
    $num = $index + 1;
    $cuenta = $ejemplo['cuenta'];
    $nombre = $ejemplo['nombre'];

    echo "=======================================================\n";
    echo "Prueba $num: $nombre\n";
    echo "=======================================================\n\n";

    $payload = [
        'eRequest' => [
            'Operacion' => 'recaudadora_descpredfrm',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_cvecat', 'tipo' => 'string', 'valor' => $cuenta]
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
                echo "Total de descuentos: " . count($result) . "\n\n";

                // Mostrar primeros 3 descuentos
                $limit = min(3, count($result));
                for ($i = 0; $i < $limit; $i++) {
                    $row = $result[$i];
                    echo "Descuento " . ($i + 1) . ":\n";
                    echo "  CVE Cuenta: {$row['cvecuenta']}\n";
                    echo "  Descripción: {$row['descripcion']}\n";
                    echo "  Porcentaje: {$row['porcentaje']}%\n";
                    echo "  Ejercicio: {$row['ejercicio']}\n";
                    echo "  Bimestres: {$row['bimini']} - {$row['bimfin']}\n";
                    echo "  Fecha Alta: {$row['fecalta']}\n";
                    echo "  Status: {$row['status_desc']}\n";
                    echo "  Solicitante: {$row['solicitante']}\n";
                    echo "  Observaciones: " . substr($row['observaciones'], 0, 60) . "...\n\n";
                }
            } else {
                echo "No se encontraron descuentos para esta cuenta\n";
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

// Prueba extra: Listar primeros descuentos
echo "=======================================================\n";
echo "Prueba Extra: Listar primeros 5 descuentos (sin filtro)\n";
echo "=======================================================\n\n";

$payloadAll = [
    'eRequest' => [
        'Operacion' => 'recaudadora_descpredfrm',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_cvecat', 'tipo' => 'string', 'valor' => '']
        ],
        'Tenant' => ''
    ]
];

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payloadAll));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode == 200) {
    $data = json_decode($response, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n";
        $result = $data['eResponse']['data']['result'];
        echo "Total de descuentos encontrados: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "Primeros 5 registros:\n\n";
            $limit = min(5, count($result));
            for ($i = 0; $i < $limit; $i++) {
                $row = $result[$i];
                echo "  " . ($i + 1) . ". CVE Cuenta {$row['cvecuenta']}: {$row['descripcion']} - {$row['porcentaje']}% ({$row['status_desc']})\n";
            }
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode\n";
}

curl_close($ch);

echo "\n\n=== FIN DE PRUEBAS ===\n\n";
echo "✓ 3 Ejemplos para probar en la interfaz Vue:\n\n";
foreach ($ejemplos as $i => $ej) {
    echo ($i + 1) . ". CVE Cuenta: {$ej['cuenta']}\n";
    echo "   {$ej['nombre']}\n\n";
}
echo "Nota: También puedes dejar el campo vacío para ver todos los descuentos.\n";
echo "\nPrimero debes ejecutar: php temp/deploy_descpredfrm.php\n";
echo "para desplegar el stored procedure en la base de datos.\n";
