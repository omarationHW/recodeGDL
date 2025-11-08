<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "DEPLOY Y TEST SP STATS OPTIMIZADO\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Desplegar SP
    echo "Desplegando SP de estadísticas...\n";
    $sql = file_get_contents('C:\\Sistemas\\RefactorX\\Guadalajara\\RecodePHP\\GDL\\temp\\sp_licencias_stats.sql');
    $pdo->exec($sql);
    echo "✓ SP desplegado\n\n";

    // Test 1: Método ACTUAL (4 consultas separadas)
    echo "========================================\n";
    echo "TEST 1: Método ACTUAL (4 consultas)\n";
    echo "========================================\n";

    $start = microtime(true);

    // Consulta 1: Total
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 1, NULL, NULL, NULL, NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $r1 = $stmt->fetch(PDO::FETCH_ASSOC);

    // Consulta 2: Vigentes
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 1, NULL, NULL, 'VIGENTE', NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $r2 = $stmt->fetch(PDO::FETCH_ASSOC);

    // Consulta 3: Suspendidas
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 1, NULL, NULL, 'SUSPENDIDA', NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $r3 = $stmt->fetch(PDO::FETCH_ASSOC);

    // Consulta 4: Temporales
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 1, NULL, NULL, 'TEMPORAL', NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $r4 = $stmt->fetch(PDO::FETCH_ASSOC);

    $duration1 = round((microtime(true) - $start) * 1000, 2);

    echo "Total licencias: " . number_format($r1['total_records']) . "\n";
    echo "Vigentes: " . number_format($r2['total_records']) . "\n";
    echo "Suspendidas: " . number_format($r3['total_records']) . "\n";
    echo "Temporales: " . number_format($r4['total_records']) . "\n";
    echo "⏱ Tiempo total: {$duration1}ms\n\n";

    // Test 2: Método NUEVO (1 consulta optimizada)
    echo "========================================\n";
    echo "TEST 2: Método NUEVO (1 consulta)\n";
    echo "========================================\n";

    $start = microtime(true);

    $stmt = $pdo->query("SELECT * FROM public.licenciasvigentesfrm_sp_stats()");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    $duration2 = round((microtime(true) - $start) * 1000, 2);

    echo "Total licencias: " . number_format($stats['total_licencias']) . "\n";
    echo "Vigentes: " . number_format($stats['total_vigentes']) . "\n";
    echo "Suspendidas: " . number_format($stats['total_suspendidas']) . "\n";
    echo "Temporales: " . number_format($stats['total_temporales']) . "\n";
    echo "Canceladas: " . number_format($stats['total_canceladas']) . "\n";
    echo "Bajas: " . number_format($stats['total_bajas']) . "\n";
    echo "⏱ Tiempo total: {$duration2}ms\n\n";

    // Comparación
    echo "========================================\n";
    echo "COMPARACIÓN\n";
    echo "========================================\n";

    $mejora = round(($duration1 / $duration2), 2);
    $ahorro = round($duration1 - $duration2, 2);

    echo "Método actual: {$duration1}ms\n";
    echo "Método nuevo: {$duration2}ms\n";
    echo "Mejora: {$mejora}x más rápido\n";
    echo "Ahorro: {$ahorro}ms\n\n";

    if ($mejora >= 2) {
        echo "✅ EXCELENTE - Mejora significativa\n";
    } elseif ($mejora >= 1.5) {
        echo "✅ BUENO - Mejora notable\n";
    } else {
        echo "⚠️ Mejora marginal\n";
    }

    echo "\n✅ Pruebas completadas\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
