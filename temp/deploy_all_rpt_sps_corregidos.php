<?php
/**
 * SCRIPT DE DESPLIEGUE MASIVO DE SPs CORREGIDOS
 * Despliega todos los archivos *_CORREGIDO.sql
 * Fecha: 2025-12-03
 */

echo "========================================\n";
echo "DESPLIEGUE MASIVO DE SPs CORREGIDOS\n";
echo "========================================\n\n";

// Configuración de conexión PostgreSQL (desde .env)
$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

// Conexión a PostgreSQL
$connString = sprintf(
    "host=%s port=%s dbname=%s user=%s password=%s",
    $config['host'],
    $config['port'],
    $config['dbname'],
    $config['user'],
    $config['password']
);

echo "Conectando a PostgreSQL...\n";
$conn = pg_connect($connString);

if (!$conn) {
    die("ERROR: No se pudo conectar a PostgreSQL\n");
}

echo "✓ Conexión exitosa\n\n";

// Directorio de archivos SQL
$sqlDir = __DIR__ . '/../RefactorX/Base/mercados/database/database/';

// Buscar todos los archivos *_CORREGIDO.sql
$files = glob($sqlDir . '*_CORREGIDO.sql');

if (empty($files)) {
    die("ERROR: No se encontraron archivos *_CORREGIDO.sql\n");
}

echo "Archivos encontrados: " . count($files) . "\n";
echo "========================================\n\n";

$success = 0;
$errors = 0;
$resultados = [];

foreach ($files as $index => $filePath) {
    $fileName = basename($filePath);
    $num = $index + 1;

    echo "[$num/" . count($files) . "] Procesando: $fileName\n";

    // Leer contenido del archivo
    $sql = file_get_contents($filePath);

    if ($sql === false) {
        echo "  ✗ ERROR: No se pudo leer el archivo\n\n";
        $errors++;
        $resultados[] = [
            'archivo' => $fileName,
            'estado' => 'ERROR',
            'mensaje' => 'No se pudo leer el archivo'
        ];
        continue;
    }

    // Extraer nombre del SP del SQL
    preg_match('/CREATE OR REPLACE FUNCTION\s+(\w+)\s*\(/i', $sql, $matches);
    $spName = $matches[1] ?? 'desconocido';

    echo "  → SP: $spName\n";

    // Ejecutar SQL
    $result = @pg_query($conn, $sql);

    if ($result) {
        echo "  ✓ Desplegado exitosamente\n\n";
        $success++;
        $resultados[] = [
            'archivo' => $fileName,
            'sp' => $spName,
            'estado' => 'OK',
            'mensaje' => 'Desplegado exitosamente'
        ];
    } else {
        $error = pg_last_error($conn);
        echo "  ✗ ERROR: $error\n\n";
        $errors++;
        $resultados[] = [
            'archivo' => $fileName,
            'sp' => $spName,
            'estado' => 'ERROR',
            'mensaje' => $error
        ];
    }

    // Pequeña pausa para evitar sobrecarga
    usleep(100000); // 0.1 segundos
}

// Cerrar conexión
pg_close($conn);

// Resumen final
echo "\n========================================\n";
echo "RESUMEN DE DESPLIEGUE\n";
echo "========================================\n";
echo "Total archivos:  " . count($files) . "\n";
echo "Exitosos:        $success ✓\n";
echo "Errores:         $errors ✗\n";
echo "Porcentaje:      " . round(($success / count($files)) * 100, 2) . "%\n";
echo "========================================\n\n";

// Reporte detallado de errores
if ($errors > 0) {
    echo "ERRORES ENCONTRADOS:\n";
    echo "========================================\n";
    foreach ($resultados as $resultado) {
        if ($resultado['estado'] === 'ERROR') {
            echo "✗ {$resultado['archivo']}\n";
            echo "  SP: {$resultado['sp']}\n";
            echo "  Error: {$resultado['mensaje']}\n\n";
        }
    }
}

// Reporte de éxitos
if ($success > 0) {
    echo "\nSPs DESPLEGADOS EXITOSAMENTE:\n";
    echo "========================================\n";
    foreach ($resultados as $resultado) {
        if ($resultado['estado'] === 'OK') {
            echo "✓ {$resultado['sp']}\n";
        }
    }
}

// Guardar reporte JSON
$reportPath = __DIR__ . '/reporte_despliegue_sps_corregidos.json';
file_put_contents($reportPath, json_encode([
    'fecha' => date('Y-m-d H:i:s'),
    'total' => count($files),
    'exitosos' => $success,
    'errores' => $errors,
    'porcentaje' => round(($success / count($files)) * 100, 2),
    'resultados' => $resultados
], JSON_PRETTY_PRINT));

echo "\n✓ Reporte guardado en: $reportPath\n";
echo "\n========================================\n";
echo "DESPLIEGUE COMPLETADO\n";
echo "========================================\n";

exit($errors > 0 ? 1 : 0);
