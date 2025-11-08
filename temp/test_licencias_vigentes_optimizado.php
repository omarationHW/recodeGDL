<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST SP LICENCIAS VIGENTES OPTIMIZADO\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Desplegar SP optimizado
    echo "Desplegando SP optimizado...\n";
    $sql = file_get_contents('C:\\Sistemas\\RefactorX\\Guadalajara\\RecodePHP\\GDL\\temp\\LicenciasVigentesfrm_sp_OPTIMIZED.sql');
    $pdo->exec($sql);
    echo "✓ SP desplegado\n\n";

    // Prueba 1: Sin filtros
    echo "========================================\n";
    echo "PRUEBA 1: Sin filtros (página 1, 10 registros)\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, NULL, NULL, NULL, NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $end = microtime(true);

    $duration = round(($end - $start) * 1000, 2);
    echo "✓ Tiempo: {$duration} ms\n";
    echo "  Registros: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "  Total en DB: " . number_format($results[0]['total_records']) . "\n";
    }
    echo "\n";

    // Prueba 2: Con filtro de estado
    echo "========================================\n";
    echo "PRUEBA 2: Filtro estado=VIGENTE (página 1, 10 registros)\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, NULL, NULL, 'VIGENTE', NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $end = microtime(true);

    $duration = round(($end - $start) * 1000, 2);
    echo "✓ Tiempo: {$duration} ms\n";
    echo "  Registros: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "  Total en DB: " . number_format($results[0]['total_records']) . "\n";
    }
    echo "\n";

    // Prueba 3: Página 2
    echo "========================================\n";
    echo "PRUEBA 3: Página 2 (registros 11-20)\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            2, 10, NULL, NULL, NULL, NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $end = microtime(true);

    $duration = round(($end - $start) * 1000, 2);
    echo "✓ Tiempo: {$duration} ms\n";
    echo "  Registros: " . count($results) . "\n";
    echo "\n";

    // Mostrar un registro de ejemplo
    if (count($results) > 0) {
        echo "========================================\n";
        echo "REGISTRO DE EJEMPLO\n";
        echo "========================================\n";
        echo "Número: " . $results[0]['numero'] . "\n";
        echo "Propietario: " . $results[0]['propietario'] . "\n";
        echo "Giro: " . $results[0]['giro'] . "\n";
        echo "Dirección: " . $results[0]['direccion'] . "\n";
        echo "Zona: " . $results[0]['zona'] . "\n";
        echo "Estado: " . $results[0]['estado'] . "\n";
        echo "Fecha: " . $results[0]['fecha_otorgamiento'] . "\n";
        echo "Vigencia: " . $results[0]['vigencia_hasta'] . "\n";
        echo "\n";
    }

    echo "✅ Todas las pruebas completadas exitosamente\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
