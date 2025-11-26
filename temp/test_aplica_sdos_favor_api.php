<?php
/**
 * Probar recaudadora_aplica_sdos_favor vía API genérica
 */

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "========================================\n";
echo "TEST: Aplicar Saldos a Favor\n";
echo "========================================\n\n";

// Primero vamos a consultar saldos disponibles
echo "1️⃣ Consultando saldos disponibles...\n\n";

$consultaPayload = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_CONSULTA_SDOS_FAVOR',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '295685'],
            ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => null],
            ['nombre' => 'p_folio', 'tipo' => 'integer', 'valor' => null]
        ],
        'Tenant' => ''
    ]
];

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($consultaPayload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);

if (isset($data['eResponse']['data']['result']) && count($data['eResponse']['data']['result']) > 0) {
    $saldo = $data['eResponse']['data']['result'][0];
    echo "✅ Saldo encontrado:\n";
    echo "  - Cuenta: {$saldo['clave_cuenta']}\n";
    echo "  - Folio: {$saldo['folio']}\n";
    echo "  - Ejercicio: {$saldo['ejercicio']}\n";
    echo "  - Saldo: {$saldo['saldo']}\n";
    echo "  - ID Solicitud: {$saldo['id_solic']}\n\n";

    // Ahora vamos a aplicar el saldo
    echo "2️⃣ Aplicando saldo a favor...\n\n";

    $registros = [
        [
            'id_solic' => $saldo['id_solic'],
            'saldo' => $saldo['saldo']
        ]
    ];

    $aplicaPayload = [
        'eRequest' => [
            'Operacion' => 'RECAUDADORA_APLICA_SDOS_FAVOR',
            'Base' => 'multas_reglamentos',
            'Parametros' => [
                ['nombre' => 'p_registros', 'tipo' => 'string', 'valor' => json_encode($registros)]
            ],
            'Tenant' => ''
        ]
    ];

    echo "📤 Enviando request para aplicar saldo...\n";
    echo "Registros a aplicar: " . json_encode($registros, JSON_UNESCAPED_UNICODE) . "\n\n";

    $ch = curl_init($apiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($aplicaPayload));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    echo "📥 Respuesta HTTP: $httpCode\n\n";

    $data = json_decode($response, true);

    echo "Respuesta:\n";
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    if (isset($data['eResponse'])) {
        $eResponse = $data['eResponse'];

        if ($eResponse['success']) {
            echo "✅ Operación exitosa\n\n";

            if (isset($eResponse['data']['result'])) {
                $result = $eResponse['data']['result'];
                if (count($result) > 0) {
                    echo "📊 Resultado:\n";
                    foreach ($result[0] as $key => $value) {
                        echo "  $key: " . ($value ?? 'NULL') . "\n";
                    }
                }
            }
        } else {
            echo "❌ Error en la operación: " . $eResponse['message'] . "\n";
        }
    }
} else {
    echo "❌ No se encontraron saldos para la cuenta 295685\n";
}

echo "\n========================================\n";
