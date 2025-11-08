<?php
/**
 * Script para probar los stored procedures de giros con adeudo
 */

$host = '192.168.6.146';
$port = '5432';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "======================================\n";
echo "TEST: SP Giros con Adeudo\n";
echo "======================================\n\n";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test 1: Verificar que existe el SP
    echo "Test 1: Verificar stored procedures\n";
    $stmt = $pdo->query("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_name IN ('sp_giros_dcon_adeudo', 'sp_report_giros_dcon_adeudo')
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_COLUMN);

    foreach ($sps as $sp) {
        echo "  ✓ Encontrado: $sp\n";
    }

    if (count($sps) === 0) {
        echo "  ✗ No se encontraron los stored procedures\n";
        exit(1);
    }

    // Test 2: Ejecutar el SP con parámetros NULL (consulta general)
    echo "\nTest 2: Ejecutar sp_giros_dcon_adeudo\n";
    $stmt = $pdo->prepare("
        SELECT * FROM public.sp_giros_dcon_adeudo(
            NULL,  -- p_year
            NULL,  -- p_giro
            NULL,  -- p_min_debt
            1,     -- p_page
            10     -- p_limit
        )
    ");

    $stmt->execute();
    $results = $stmt->fetchAll();

    echo "  Registros encontrados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\n  Primeros 3 resultados:\n";
        $count = min(3, count($results));
        for ($i = 0; $i < $count; $i++) {
            $row = $results[$i];
            echo "  " . ($i+1) . ". Giro: {$row['giro']}\n";
            echo "     Total Licencias: {$row['total_licencias']}\n";
            echo "     Con Adeudo: {$row['licencias_con_adeudo']}\n";
            echo "     Monto Total: $" . number_format($row['monto_total_adeudo'], 2) . "\n\n";
        }
    } else {
        echo "  ⚠ No se encontraron giros con adeudo\n";
    }

    echo "======================================\n";
    echo "TESTS COMPLETADOS EXITOSAMENTE\n";
    echo "======================================\n";

} catch (PDOException $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
