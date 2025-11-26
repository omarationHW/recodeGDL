<?php
/**
 * Probar el SP recaudadora_get_ejecutores
 */

$url = 'http://127.0.0.1:8000/api/generic';

echo "=== PROBANDO SP GET_EJECUTORES ===\n\n";

$data = [
    'eRequest' => [
        'Operacion' => 'RECAUDADORA_GET_EJECUTORES',
        'Base' => 'multas_reglamentos',
        'Parametros' => [],
        'Tenant' => ''
    ]
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $http_code\n\n";

if ($http_code === 200 && $response) {
    $json = json_decode($response, true);
    echo "Respuesta completa:\n";
    echo json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    if (isset($json['eResponse']['data']['result'])) {
        $ejecutores = $json['eResponse']['data']['result'];
        echo "Ejecutores encontrados: " . count($ejecutores) . "\n\n";

        if (count($ejecutores) > 0) {
            echo "Primeros 5 ejecutores:\n";
            foreach (array_slice($ejecutores, 0, 5) as $e) {
                echo "  - ID: {$e['cveejecutor']} | Empresa: {$e['empresa']}\n";
            }
        } else {
            echo "⚠️  No hay ejecutores en la base de datos\n";
        }
    } else {
        echo "❌ La respuesta no contiene 'result'\n";
    }
} else {
    echo "❌ Error en la petición\n";
    if ($response) {
        $json = json_decode($response, true);
        if (isset($json['eResponse']['message'])) {
            echo "Mensaje: {$json['eResponse']['message']}\n";
        }
    }
}

// Probar también directamente en la BD
echo "\n=== VERIFICANDO EN BD ===\n\n";

$conn = @pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if ($conn) {
    // Verificar si el SP existe
    $query = "
    SELECT proname, pronargs
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE proname = 'recaudadora_get_ejecutores'
        AND n.nspname = 'public'
    ";
    $result = pg_query($conn, $query);

    if (pg_num_rows($result) > 0) {
        echo "✓ SP recaudadora_get_ejecutores existe\n";

        // Probar llamar al SP
        $query = "SELECT * FROM recaudadora_get_ejecutores()";
        $result = pg_query($conn, $query);

        if ($result) {
            $count = pg_num_rows($result);
            echo "✓ SP ejecutado correctamente\n";
            echo "✓ Ejecutores encontrados: $count\n\n";

            if ($count > 0) {
                echo "Primeros 5 ejecutores:\n";
                $i = 0;
                while ($row = pg_fetch_assoc($result) and $i < 5) {
                    echo "  - ID: {$row['cveejecutor']} | Empresa: {$row['empresa']}\n";
                    $i++;
                }
            } else {
                echo "⚠️  El SP no devuelve datos (tabla ejecutores vacía?)\n";
            }
        } else {
            echo "✗ Error al ejecutar SP: " . pg_last_error($conn) . "\n";
        }
    } else {
        echo "✗ SP recaudadora_get_ejecutores NO existe\n";
        echo "   Necesita ser creado\n";
    }

    pg_close($conn);
} else {
    echo "⚠️  No se pudo conectar a la BD (esto es normal desde tu ubicación)\n";
}

echo "\n✅ Pruebas completadas.\n";
