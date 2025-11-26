<?php
$url = 'http://127.0.0.1:8000/api/generic';
$data = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_BLOQUEO_MULTA',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'valor' => '', 'tipo' => 'string'],
            ['nombre' => 'p_ejercicio', 'valor' => 2022, 'tipo' => 'int'],
            ['nombre' => 'p_offset', 'valor' => 0, 'tipo' => 'int'],
            ['nombre' => 'p_limit', 'valor' => 5, 'tipo' => 'int']
        ],
        'Tenant' => ''
    ]
];
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);
$json = json_decode($response, true);
echo 'Registros encontrados: ' . $json['eResponse']['data']['count'] . "\n";
if ($json['eResponse']['data']['count'] > 0) {
    echo "\nPrimera fila:\n";
    print_r($json['eResponse']['data']['result'][0]);

    echo "\n\nESTRUCTURA EN EL FRONTEND:\n";
    echo "data.result es un array: " . (is_array($json['eResponse']['data']['result']) ? 'SÍ' : 'NO') . "\n";
    echo "data.result tiene elementos: " . count($json['eResponse']['data']['result']) . "\n";
} else {
    echo "\n⚠️  No hay datos para el año 2022\n";
}
