<?php
// Script para probar la API de DescDerechosMerc

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API DescDerechosMerc ===\n\n";

// Ejemplos de cuentas (id_local) con descuentos
$ejemplos = [
    ['cuenta' => '1', 'nombre' => 'Cuenta 1 - Local en Mercado 1'],
    ['cuenta' => '2', 'nombre' => 'Cuenta 2 - Local en Mercado 1'],
    ['cuenta' => '3', 'nombre' => 'Cuenta 3 - Local en Mercado 1']
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
            'Operacion' => 'recaudadora_descderechos_merc',
            'Base' => 'multas_reglamentos',
            'Esquema' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => $cuenta],
                ['nombre' => 'p_ejercicio', 'tipo' => 'int', 'valor' => 2024]
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
                    echo "  Cuenta: {$row['clave_cuenta']}\n";
                    echo "  Local: {$row['nombre']}\n";
                    echo "  Mercado: {$row['num_mercado']}, Local: {$row['local']}\n";
                    echo "  Descuento: {$row['descuento']}%\n";
                    echo "  Desde: {$row['desde']} - Hasta: {$row['hasta']}\n";
                    echo "  Estatus: {$row['estatus']}\n\n";
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

// Prueba extra: Listar todos los descuentos
echo "=======================================================\n";
echo "Prueba Extra: Listar TODOS los descuentos (sin filtro)\n";
echo "=======================================================\n\n";

$payloadAll = [
    'eRequest' => [
        'Operacion' => 'recaudadora_descderechos_merc',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => ''],
            ['nombre' => 'p_ejercicio', 'tipo' => 'int', 'valor' => 2024]
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
            echo "Primeros 3 registros:\n\n";
            $limit = min(3, count($result));
            for ($i = 0; $i < $limit; $i++) {
                $row = $result[$i];
                echo "  " . ($i + 1) . ". Cuenta {$row['clave_cuenta']}: {$row['nombre']} - {$row['descuento']}% ({$row['estatus']})\n";
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
echo "Puedes usar estas cuentas en la interfaz Vue:\n";
foreach ($ejemplos as $i => $ej) {
    echo ($i + 1) . ". Cuenta {$ej['cuenta']}\n";
}
echo "\nNota: También puedes dejar el campo vacío para ver todos los descuentos.\n";
echo "\nPrimero debes ejecutar: php temp/deploy_descderechos_merc.php\n";
echo "para desplegar el stored procedure en la base de datos.\n";
