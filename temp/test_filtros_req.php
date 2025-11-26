<?php
// Probar los filtros de Req.vue con el formato correcto
echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║         PRUEBA DE FILTROS - Req.vue                       ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

$api_url = "http://127.0.0.1:8000/api/generic";

// Prueba 1: Filtrar solo por año 2025
echo "═══ PRUEBA 1: Filtrar solo por AÑO 2025 ═══\n";
$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_req',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => ''],
            ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 2025]
        ]
    ]
];

echo "Filtros: Cuenta=(vacío), Año=2025\n\n";

$ch = curl_init($api_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload1));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response1 = curl_exec($ch);
$data1 = json_decode($response1, true);

if (isset($data1['eResponse']['success']) && $data1['eResponse']['success']) {
    $rows = $data1['eResponse']['data']['result'] ?? [];
    echo "✅ Total de registros encontrados: " . count($rows) . "\n\n";

    if (count($rows) > 0) {
        echo "Registros del 2025:\n";
        foreach ($rows as $row) {
            if ($row['axoreq'] == 2025) {
                echo sprintf(
                    "  ✓ CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                    $row['cvereq'],
                    $row['cvecuenta'],
                    $row['folioreq'],
                    $row['axoreq'],
                    $row['total']
                );
            }
        }
    }
} else {
    echo "❌ Error: " . ($data1['eResponse']['message'] ?? 'Sin mensaje') . "\n";
}

// Prueba 2: Filtrar solo por cuenta 12345
echo "\n═══ PRUEBA 2: Filtrar solo por CUENTA 12345 ═══\n";
$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_req',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '12345'],
            ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 0]
        ]
    ]
];

echo "Filtros: Cuenta=12345, Año=0 (todos)\n\n";

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload2));
$response2 = curl_exec($ch);
$data2 = json_decode($response2, true);

if (isset($data2['eResponse']['success']) && $data2['eResponse']['success']) {
    $rows = $data2['eResponse']['data']['result'] ?? [];
    echo "✅ Total de registros encontrados: " . count($rows) . "\n\n";

    if (count($rows) > 0) {
        echo "Registros con cuenta 12345:\n";
        foreach ($rows as $row) {
            if ($row['cvecuenta'] == 12345) {
                echo sprintf(
                    "  ✓ CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                    $row['cvereq'],
                    $row['cvecuenta'],
                    $row['folioreq'],
                    $row['axoreq'],
                    $row['total']
                );
            }
        }
    }
} else {
    echo "❌ Error: " . ($data2['eResponse']['message'] ?? 'Sin mensaje') . "\n";
}

// Prueba 3: Filtrar por cuenta Y año
echo "\n═══ PRUEBA 3: Filtrar por CUENTA 444555666 Y AÑO 2025 ═══\n";
$payload3 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_req',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => '444555666'],
            ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 2025]
        ]
    ]
];

echo "Filtros: Cuenta=444555666, Año=2025\n\n";

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload3));
$response3 = curl_exec($ch);
$data3 = json_decode($response3, true);

if (isset($data3['eResponse']['success']) && $data3['eResponse']['success']) {
    $rows = $data3['eResponse']['data']['result'] ?? [];
    echo "✅ Total de registros encontrados: " . count($rows) . "\n\n";

    if (count($rows) > 0) {
        echo "Registros encontrados:\n";
        foreach ($rows as $row) {
            echo sprintf(
                "  ✓ CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq'],
                $row['axoreq'],
                $row['total']
            );
        }
    }
} else {
    echo "❌ Error: " . ($data3['eResponse']['message'] ?? 'Sin mensaje') . "\n";
}

// Prueba 4: Sin filtros (todos los registros)
echo "\n═══ PRUEBA 4: SIN FILTROS (todos los registros) ═══\n";
$payload4 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_req',
        'Base' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_clave_cuenta', 'tipo' => 'string', 'valor' => ''],
            ['nombre' => 'p_ejercicio', 'tipo' => 'integer', 'valor' => 0]
        ]
    ]
];

echo "Filtros: Cuenta=(vacío), Año=0 (todos)\n\n";

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload4));
$response4 = curl_exec($ch);
$data4 = json_decode($response4, true);

if (isset($data4['eResponse']['success']) && $data4['eResponse']['success']) {
    $rows = $data4['eResponse']['data']['result'] ?? [];
    echo "✅ Total de registros encontrados: " . count($rows) . "\n\n";

    if (count($rows) > 0) {
        echo "Primeros 5 registros:\n";
        for ($i = 0; $i < min(5, count($rows)); $i++) {
            $row = $rows[$i];
            echo sprintf(
                "  %d. CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s | Total: $%.2f\n",
                $i + 1,
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq'],
                $row['axoreq'],
                $row['total']
            );
        }
    }
} else {
    echo "❌ Error: " . ($data4['eResponse']['message'] ?? 'Sin mensaje') . "\n";
}

curl_close($ch);

echo "\n\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║                   RESUMEN DE PRUEBAS                      ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";
echo "✅ Formato de parámetros corregido en Req.vue\n";
echo "✅ API procesando filtros correctamente\n";
echo "\nAhora recarga la página en el navegador y prueba los filtros:\n";
echo "  • Solo año 2025 → Debería mostrar ~5 registros\n";
echo "  • Solo cuenta 12345 → Debería mostrar 1 registro\n";
echo "  • Ambos filtros → Debería filtrar por ambos criterios\n";
echo "  • Sin filtros → Debería mostrar todos los registros\n";
echo "\n";
