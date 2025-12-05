<?php
// Script para probar la API de descmultampalfrm

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API DescMultaMpalFrm ===\n\n";

// Ejemplos de ID Multas con descuentos
$ejemplos = [
    ['cuenta' => '191', 'nombre' => 'Multa 191 - AGUA ARCO IRIS - 50% descuento'],
    ['cuenta' => '224', 'nombre' => 'Multa 224 - JOSE GUDIÑO SANTANA - 50% descuento'],
    ['cuenta' => '241', 'nombre' => 'Multa 241 - CRISTINA PANDURO - 80% descuento']
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
            'Operacion' => 'recaudadora_descmultampalfrm',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => $cuenta]
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
                foreach ($result as $i => $row) {
                    echo "Descuento " . ($i + 1) . ":\n";
                    echo "  ID Multa: {$row['id_multa']}\n";
                    echo "  Acta: {$row['num_acta']}\n";
                    echo "  Fecha Acta: {$row['fecha_acta']}\n";
                    echo "  Contribuyente: {$row['contribuyente']}\n";
                    echo "  Domicilio: {$row['domicilio']}\n";
                    echo "  Multa: \${$row['multa']}\n";
                    echo "  Total: \${$row['total']}\n";
                    echo "  Tipo Descuento: {$row['tipo_descto']}\n";
                    echo "  Valor: {$row['valor_descuento']}" . ($row['tipo_descto'] === 'Porcentaje' ? '%' : '') . "\n";
                    echo "  Estado: {$row['estado_desc']}\n";
                    echo "  Fecha Descuento: {$row['fecha_descuento']}\n";
                    echo "  Observación: {$row['observacion']}\n\n";
                }
            } else {
                echo "No se encontraron descuentos para esta multa\n";
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

// Prueba extra: Listar todos los descuentos
echo "=======================================================\n";
echo "Prueba Extra: Listar TODOS los descuentos (sin filtro)\n";
echo "=======================================================\n\n";

$payloadAll = [
    'eRequest' => [
        'Operacion' => 'recaudadora_descmultampalfrm',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '']
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
                echo "  " . ($i + 1) . ". Multa {$row['id_multa']}: {$row['contribuyente']} - {$row['valor_descuento']}";
                echo ($row['tipo_descto'] === 'Porcentaje' ? '%' : '');
                echo " ({$row['estado_desc']})\n";
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
    echo ($i + 1) . ". ID Multa: {$ej['cuenta']}\n";
    echo "   {$ej['nombre']}\n\n";
}
echo "Nota: También puedes dejar el campo vacío para ver todos los descuentos.\n";
echo "\nPrimero debes ejecutar: php temp/deploy_descmultampalfrm.php\n";
echo "para desplegar el stored procedure en la base de datos.\n";
