<?php
/**
 * Script para probar la API de Empresas
 * Simula las llamadas que hace el formulario Vue
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

$api_url = 'http://localhost:8000/api/execute';

echo "=== PRUEBAS DE API EMPRESAS ===\n\n";

// Función helper para hacer llamadas a la API
function callAPI($url, $operacion, $base, $parametros) {
    $eRequest = [
        'Operacion' => $operacion,
        'Base' => $base,
        'Parametros' => $parametros,
        'Tenant' => ''
    ];

    $data = ['eRequest' => $eRequest];

    $options = [
        'http' => [
            'header'  => "Content-Type: application/json\r\n",
            'method'  => 'POST',
            'content' => json_encode($data),
            'ignore_errors' => true
        ]
    ];

    $context  = stream_context_create($options);
    $result = file_get_contents($url, false, $context);

    if ($result === FALSE) {
        return ['error' => 'Error al conectar con la API'];
    }

    return json_decode($result, true);
}

// EJEMPLO 1: Buscar todos los registros (primera página)
echo "=== EJEMPLO 1: Buscar todos (Primera página - 10 registros) ===\n";
echo "Campo Nombre: [vacío]\n\n";

$params = [
    ['nombre' => 'q', 'tipo' => 'string', 'valor' => ''],
    ['nombre' => 'offset', 'tipo' => 'integer', 'valor' => 0],
    ['nombre' => 'limit', 'tipo' => 'integer', 'valor' => 10]
];

$response = callAPI($api_url, 'recaudadora_empresas', 'multas_reglamentos', $params);

if (isset($response['error'])) {
    echo "❌ Error: {$response['error']}\n";
} else if (isset($response['eResponse']['success']) && $response['eResponse']['success']) {
    $rows = $response['eResponse']['data'] ?? [];

    echo "✅ Respuesta exitosa\n";
    echo "📄 Registros en esta página: " . count($rows) . "\n";

    if (count($rows) > 0) {
        $total = $rows[0]['total_count'] ?? count($rows);
        echo "📊 Total de empresas: $total\n\n";

        echo "Primeros registros:\n";
        foreach (array_slice($rows, 0, 5) as $i => $row) {
            echo ($i + 1) . ". Empresa: {$row['empresa']}\n";
            echo "   RFC: {$row['rfc']}\n";
            echo "   Contacto: {$row['contacto']}\n";
            echo "   Estatus: {$row['estatus']}\n";
            echo "   ---\n";
        }
    }
} else {
    echo "❌ Error en la respuesta:\n";
    echo json_encode($response, JSON_PRETTY_PRINT) . "\n";
}

echo "\n\n";

// EJEMPLO 2: Buscar por nombre "EJECUTOR"
echo "=== EJEMPLO 2: Buscar por nombre 'EJECUTOR' ===\n";
echo "Campo Nombre: EJECUTOR\n\n";

$params = [
    ['nombre' => 'q', 'tipo' => 'string', 'valor' => 'EJECUTOR'],
    ['nombre' => 'offset', 'tipo' => 'integer', 'valor' => 0],
    ['nombre' => 'limit', 'tipo' => 'integer', 'valor' => 10]
];

$response = callAPI($api_url, 'recaudadora_empresas', 'multas_reglamentos', $params);

if (isset($response['error'])) {
    echo "❌ Error: {$response['error']}\n";
} else if (isset($response['eResponse']['success']) && $response['eResponse']['success']) {
    $rows = $response['eResponse']['data'] ?? [];

    echo "✅ Respuesta exitosa\n";
    echo "📄 Registros en esta página: " . count($rows) . "\n";

    if (count($rows) > 0) {
        $total = $rows[0]['total_count'] ?? count($rows);
        echo "📊 Total de empresas que coinciden: $total\n\n";

        echo "Registros encontrados:\n";
        foreach ($rows as $i => $row) {
            echo ($i + 1) . ". Empresa: {$row['empresa']}\n";
            echo "   RFC: {$row['rfc']}\n";
            echo "   Contacto: {$row['contacto']}\n";
            echo "   Estatus: {$row['estatus']}\n";
            echo "   ---\n";
        }
    } else {
        echo "No se encontraron registros con ese filtro\n";
    }
} else {
    echo "❌ Error en la respuesta:\n";
    echo json_encode($response, JSON_PRETTY_PRINT) . "\n";
}

echo "\n\n";

// EJEMPLO 3: Buscar por categoría "NOTIFICADOR"
echo "=== EJEMPLO 3: Buscar por contacto/categoría 'NOTIFICADOR' ===\n";
echo "Campo Nombre: NOTIFICADOR\n\n";

$params = [
    ['nombre' => 'q', 'tipo' => 'string', 'valor' => 'NOTIFICADOR'],
    ['nombre' => 'offset', 'tipo' => 'integer', 'valor' => 0],
    ['nombre' => 'limit', 'tipo' => 'integer', 'valor' => 10]
];

$response = callAPI($api_url, 'recaudadora_empresas', 'multas_reglamentos', $params);

if (isset($response['error'])) {
    echo "❌ Error: {$response['error']}\n";
} else if (isset($response['eResponse']['success']) && $response['eResponse']['success']) {
    $rows = $response['eResponse']['data'] ?? [];

    echo "✅ Respuesta exitosa\n";
    echo "📄 Registros en esta página: " . count($rows) . "\n";

    if (count($rows) > 0) {
        $total = $rows[0]['total_count'] ?? count($rows);
        echo "📊 Total de empresas que coinciden: $total\n\n";

        echo "Registros encontrados:\n";
        foreach ($rows as $i => $row) {
            echo ($i + 1) . ". Empresa: {$row['empresa']}\n";
            echo "   RFC: {$row['rfc']}\n";
            echo "   Contacto: {$row['contacto']}\n";
            echo "   Estatus: {$row['estatus']}\n";
            echo "   ---\n";
        }
    } else {
        echo "No se encontraron registros con ese filtro\n";
    }
} else {
    echo "❌ Error en la respuesta:\n";
    echo json_encode($response, JSON_PRETTY_PRINT) . "\n";
}

echo "\n\n";

// EJEMPLO ADICIONAL: Prueba de paginación
echo "=== EJEMPLO ADICIONAL: Paginación (Segunda página, 5 registros) ===\n";
echo "Campo Nombre: [vacío]\n";
echo "Offset: 5, Limit: 5\n\n";

$params = [
    ['nombre' => 'q', 'tipo' => 'string', 'valor' => ''],
    ['nombre' => 'offset', 'tipo' => 'integer', 'valor' => 5],
    ['nombre' => 'limit', 'tipo' => 'integer', 'valor' => 5]
];

$response = callAPI($api_url, 'recaudadora_empresas', 'multas_reglamentos', $params);

if (isset($response['error'])) {
    echo "❌ Error: {$response['error']}\n";
} else if (isset($response['eResponse']['success']) && $response['eResponse']['success']) {
    $rows = $response['eResponse']['data'] ?? [];

    echo "✅ Respuesta exitosa\n";
    echo "📄 Registros en esta página: " . count($rows) . "\n";

    if (count($rows) > 0) {
        $total = $rows[0]['total_count'] ?? count($rows);
        echo "📊 Total de empresas: $total\n";
        echo "📍 Mostrando del 6 al 10\n\n";

        echo "Registros (página 2):\n";
        foreach ($rows as $i => $row) {
            echo ($i + 6) . ". Empresa: {$row['empresa']}\n";
            echo "   RFC: {$row['rfc']}\n";
            echo "   Contacto: {$row['contacto']}\n";
            echo "   ---\n";
        }
    }
} else {
    echo "❌ Error en la respuesta:\n";
    echo json_encode($response, JSON_PRETTY_PRINT) . "\n";
}

echo "\n=== FIN DE LAS PRUEBAS ===\n";
echo "\nNOTA: Si ves errores de conexión, verifica que:\n";
echo "  1. PostgreSQL esté corriendo\n";
echo "  2. El backend de Laravel esté corriendo (php artisan serve)\n";
echo "  3. El SP esté desplegado (ejecuta: php temp/deploy_empresas.php)\n";
?>
