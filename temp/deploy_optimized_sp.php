<?php
/**
 * Script para desplegar los stored procedures optimizados de giros con adeudo
 */

$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "DEPLOY: SPs Optimizados Giros Adeudo\n";
echo "========================================\n\n";

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n\n";

    // Leer el archivo SQL optimizado
    $sqlFile = 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\sp_giros_con_adeudo_OPTIMIZADO.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Ejecutando stored procedures optimizados...\n";
    $pdo->exec($sql);
    echo "   ✓ Stored procedures actualizados\n\n";

    // Test de performance - ANTES vs DESPUÉS
    echo "2. TEST DE PERFORMANCE:\n\n";

    // Test con los datos optimizados
    echo "   Ejecutando consulta optimizada (10 registros)...\n";

    $start = microtime(true);

    $stmt = $pdo->prepare("
        SELECT * FROM public.sp_giros_dcon_adeudo(NULL, NULL, NULL, 1, 10)
    ");
    $stmt->execute();
    $results = $stmt->fetchAll();

    $end = microtime(true);
    $duration = round(($end - $start) * 1000, 2);

    echo "   ✓ Tiempo de ejecución: {$duration} ms\n";
    echo "   Registros retornados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "   Total de giros: " . number_format($results[0]['total_records']) . "\n\n";

        echo "   Top 3 giros con mayor adeudo:\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $row = $results[$i];
            echo "   " . ($i+1) . ". " . substr($row['giro'], 0, 50) . "\n";
            echo "      Monto: $" . number_format($row['monto_total_adeudo'], 2) . "\n";
            echo "      Licencias con adeudo: " . $row['licencias_con_adeudo'] . "/" . $row['total_licencias'] . "\n";
        }
        echo "\n";
    }

    // Test consulta completa
    echo "3. TEST: Consulta completa (exportación)...\n";

    $start = microtime(true);

    $stmt2 = $pdo->prepare("
        SELECT * FROM public.sp_report_giros_dcon_adeudo(NULL, NULL, NULL)
    ");
    $stmt2->execute();
    $fullResults = $stmt2->fetchAll();

    $end = microtime(true);
    $duration2 = round(($end - $start) * 1000, 2);

    echo "   ✓ Tiempo de ejecución: {$duration2} ms\n";
    echo "   Total de registros: " . count($fullResults) . "\n\n";

    // Comparación
    echo "========================================\n";
    echo "✅ COMPARACIÓN DE PERFORMANCE\n";
    echo "========================================\n\n";

    $improvementPercent = round((1 - ($duration / 25555.88)) * 100, 1);

    echo "ANTES (versión original):\n";
    echo "- Tiempo: 25,555.88 ms (~25.6 segundos)\n";
    echo "- Técnica: EXISTS subqueries anidados\n\n";

    echo "DESPUÉS (versión optimizada):\n";
    echo "- Tiempo: {$duration} ms (" . round($duration / 1000, 2) . " segundos)\n";
    echo "- Técnica: LEFT JOIN + CTE pre-agregado\n";
    echo "- Mejora: {$improvementPercent}% más rápido\n\n";

    if ($duration < 1000) {
        echo "🎯 EXCELENTE: Performance sub-segundo alcanzada!\n\n";
    } elseif ($duration < 3000) {
        echo "✓ BUENO: Performance aceptable (<3 segundos)\n\n";
    } else {
        echo "⚠ ATENCIÓN: Aún hay espacio para optimización\n\n";
    }

    echo "RECOMENDACIONES ADICIONALES:\n";
    echo "1. Ejecutar VACUUM ANALYZE en tablas comun.licencias y comun.adeudos\n";
    echo "2. Los índices fueron creados automáticamente\n";
    echo "3. Considerar materializar la vista si se consulta frecuentemente\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n✗ Error:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}
