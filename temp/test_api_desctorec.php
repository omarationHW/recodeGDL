<?php
// Script para probar la API de desctorec

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API DescToRec ===\n\n";

// Ejemplos de CVE Cuentas con descuentos
$ejemplos = [
    ['cuenta' => '8', 'nombre' => 'CVE Cuenta 8 - Descuento 75% en recargos'],
    ['cuenta' => '17', 'nombre' => 'CVE Cuenta 17 - Descuentos 30% y 75%'],
    ['cuenta' => '40', 'nombre' => 'CVE Cuenta 40 - Descuentos 50% y 75%']
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
            'Operacion' => 'recaudadora_desctorec',
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
                echo "Total de descuentos: " . count($result) . "\n\n";

                // Mostrar todos los descuentos
                foreach ($result as $i => $row) {
                    echo "Descuento " . ($i + 1) . ":\n";
                    echo "  CVE Cuenta: {$row['cvecuenta']}\n";
                    echo "  Porcentaje: {$row['porcentaje']}%\n";
                    echo "  Periodo: {$row['axoini']}/{$row['bimini']} - {$row['axofin']}/{$row['bimfin']}\n";
                    echo "  Fecha Alta: {$row['fecalta']}\n";
                    echo "  Capturista Alta: {$row['captalta']}\n";
                    echo "  Vigencia: {$row['vigencia_desc']}\n";
                    if ($row['fecbaja'] && $row['fecbaja'] !== 'null') {
                        echo "  Fecha Baja: {$row['fecbaja']}\n";
                    }
                    echo "\n";
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

echo "=== FIN DE PRUEBAS ===\n\n";
echo "✓ 3 Ejemplos para probar en la interfaz Vue:\n\n";
foreach ($ejemplos as $i => $ej) {
    echo ($i + 1) . ". CVE Cuenta: {$ej['cuenta']}\n";
    echo "   {$ej['nombre']}\n\n";
}
echo "\nPrimero debes ejecutar: php temp/deploy_desctorec.php\n";
echo "para desplegar el stored procedure en la base de datos.\n";
