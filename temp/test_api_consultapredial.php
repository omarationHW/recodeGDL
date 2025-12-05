<?php
// Script para probar la API de ConsultaPredial

$apiUrl = 'http://127.0.0.1:8000/api/generic';

echo "=== PRUEBA DE API ConsultaPredial ===\n\n";

// Get some sample claves catastrales first
try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== OBTENIENDO CLAVES CATASTRALES DE EJEMPLO ===\n\n";

    $stmt = $pdo->query("
        SELECT cvecatnva, cvecuenta, saldo, val1_valfiscal
        FROM catastro_gdl.controladora
        WHERE cvecatnva IS NOT NULL
        AND vigente = 'V'
        LIMIT 3
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Ejemplos encontrados:\n";
    foreach ($samples as $i => $row) {
        echo ($i + 1) . ". Clave: {$row['cvecatnva']}, Cuenta: {$row['cvecuenta']}, Saldo: {$row['saldo']}, Val Fiscal: {$row['val1_valfiscal']}\n";
    }
    echo "\n\n";

} catch (Exception $e) {
    echo "Error obteniendo ejemplos: " . $e->getMessage() . "\n";
    exit(1);
}

// Prueba 1: Primera clave catastral
echo "=======================================================\n";
echo "Prueba 1: Buscar predial con clave '{$samples[0]['cvecatnva']}'\n";
echo "=======================================================\n\n";

$payload1 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consultapredial',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_cvecat', 'tipo' => 'string', 'valor' => $samples[0]['cvecatnva']]
        ],
        'Tenant' => ''
    ]
];

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload1));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response1 = curl_exec($ch);
$httpCode1 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode1 == 200) {
    $data = json_decode($response1, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n\n";
        $result = $data['eResponse']['data']['result'];
        if (count($result) > 0) {
            $row = $result[0];
            echo "Información del Predio:\n";
            echo "  Clave Catastral: {$row['cvecatnva']}\n";
            echo "  Cuenta: {$row['cvecuenta']}\n";
            echo "  Vigente: {$row['vigente']}\n";
            echo "  Saldo: $" . number_format($row['saldo'], 2) . "\n";
            echo "  Año Adeudo: {$row['axoadeudo']}\n";
            echo "  Valor Fiscal: $" . number_format($row['val_fiscal'], 2) . "\n";
            echo "  Área Terreno: {$row['area_terreno']} m²\n";
            echo "  Área Construcción: {$row['area_construccion']} m²\n";
            echo "  Tipo Predio: " . ($row['tipo_predio'] ?: 'N/A') . "\n";
            echo "  Urbano/Rústico: {$row['urbano_rustico']}\n";
            echo "  Exenta: " . ($row['exenta'] === ' ' ? 'No' : 'Sí') . "\n";
            echo "  Bloqueado: " . ($row['bloqueado'] ?: 'No') . "\n";
        } else {
            echo "No se encontraron resultados\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode1\n";
    echo "Respuesta: $response1\n";
}

echo "\n\n";

// Prueba 2: Segunda clave catastral
echo "=======================================================\n";
echo "Prueba 2: Buscar predial con clave '{$samples[1]['cvecatnva']}'\n";
echo "=======================================================\n\n";

$payload2 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consultapredial',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_cvecat', 'tipo' => 'string', 'valor' => $samples[1]['cvecatnva']]
        ],
        'Tenant' => ''
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload2));
$response2 = curl_exec($ch);
$httpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode2 == 200) {
    $data = json_decode($response2, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n\n";
        $result = $data['eResponse']['data']['result'];
        if (count($result) > 0) {
            $row = $result[0];
            echo "Información del Predio:\n";
            echo "  Clave Catastral: {$row['cvecatnva']}\n";
            echo "  Cuenta: {$row['cvecuenta']}\n";
            echo "  Saldo: $" . number_format($row['saldo'], 2) . "\n";
            echo "  Valor Fiscal: $" . number_format($row['val_fiscal'], 2) . "\n";
            echo "  Área Total: " . ($row['area_terreno'] + $row['area_construccion']) . " m²\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode2\n";
}

echo "\n\n";

// Prueba 3: Tercera clave catastral
echo "=======================================================\n";
echo "Prueba 3: Buscar predial con clave '{$samples[2]['cvecatnva']}'\n";
echo "=======================================================\n\n";

$payload3 = [
    'eRequest' => [
        'Operacion' => 'recaudadora_consultapredial',
        'Base' => 'multas_reglamentos',
        'Esquema' => 'multas_reglamentos',
        'Parametros' => [
            ['nombre' => 'p_cvecat', 'tipo' => 'string', 'valor' => $samples[2]['cvecatnva']]
        ],
        'Tenant' => ''
    ]
];

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload3));
$response3 = curl_exec($ch);
$httpCode3 = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpCode3 == 200) {
    $data = json_decode($response3, true);
    if ($data['eResponse']['success']) {
        echo "✓ Respuesta exitosa\n\n";
        $result = $data['eResponse']['data']['result'];
        if (count($result) > 0) {
            $row = $result[0];
            echo "Información del Predio:\n";
            echo "  Clave Catastral: {$row['cvecatnva']}\n";
            echo "  Cuenta: {$row['cvecuenta']}\n";
            echo "  Saldo: $" . number_format($row['saldo'], 2) . "\n";
            echo "  Valor Fiscal: $" . number_format($row['val_fiscal'], 2) . "\n";
            echo "  Urbano/Rústico: " . ($row['urbano_rustico'] === 'U' ? 'Urbano' : 'Rústico') . "\n";
        }
    } else {
        echo "✗ Error: " . $data['eResponse']['message'] . "\n";
    }
} else {
    echo "✗ Error HTTP $httpCode3\n";
}

curl_close($ch);

echo "\n\n=== FIN DE PRUEBAS ===\n";
echo "\nPuedes usar cualquiera de estas claves catastrales en la interfaz Vue:\n";
foreach ($samples as $i => $row) {
    echo ($i + 1) . ". {$row['cvecatnva']}\n";
}
