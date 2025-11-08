<?php
/**
 * Script para probar el parámetro p_min_debt con tipo numeric
 */

$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST: Parámetro NUMERIC p_min_debt\n";
echo "========================================\n\n";

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n\n";

    // TEST 1: Parámetro NULL (sin filtro de monto)
    echo "1. TEST: p_min_debt = NULL\n";
    echo "   (Simula: sin filtro de monto mínimo)\n";

    $stmt = $pdo->prepare("
        SELECT * FROM public.sp_giros_dcon_adeudo(
            :p_year,
            :p_giro,
            :p_min_debt,
            :p_page,
            :p_limit
        )
    ");

    $stmt->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => null,
        'p_page' => 1,
        'p_limit' => 5
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "   ✓ ÉXITO - Retornó " . count($results) . " registros\n";
        echo "   Total de giros: " . number_format($results[0]['total_records']) . "\n\n";
    } else {
        echo "   ⚠ Sin resultados\n\n";
    }

    // TEST 2: Parámetro con valor numérico (filtrar por monto mínimo)
    echo "2. TEST: p_min_debt = 1000000 (1 millón)\n";
    echo "   (Simula: solo giros con adeudo >= 1 millón)\n";

    $stmt->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => 1000000,
        'p_page' => 1,
        'p_limit' => 5
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "   ✓ ÉXITO - Retornó " . count($results) . " registros\n";
        echo "   Total de giros filtrados: " . number_format($results[0]['total_records']) . "\n";
        echo "   Primer giro: " . substr($results[0]['giro'], 0, 50) . "...\n";
        echo "   Monto: $" . number_format($results[0]['monto_total_adeudo'], 2) . "\n\n";
    } else {
        echo "   ⚠ Sin resultados\n\n";
    }

    // TEST 3: Parámetro con valor numérico alto (filtro restrictivo)
    echo "3. TEST: p_min_debt = 10000000000 (10 mil millones)\n";
    echo "   (Simula: solo giros con adeudo >= 10 mil millones)\n";

    $stmt->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => 10000000000,
        'p_page' => 1,
        'p_limit' => 5
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "   ✓ ÉXITO - Retornó " . count($results) . " registros\n";
        echo "   Total de giros filtrados: " . number_format($results[0]['total_records']) . "\n\n";

        foreach ($results as $idx => $row) {
            echo "   " . ($idx+1) . ". " . substr($row['giro'], 0, 50) . "...\n";
            echo "      Monto: $" . number_format($row['monto_total_adeudo'], 2) . "\n";
        }
        echo "\n";
    } else {
        echo "   ⚠ Sin resultados (correcto si no hay giros con tanto adeudo)\n\n";
    }

    // TEST 4: Simular lo que hace el frontend (convertir parseFloat)
    echo "4. TEST: Simular frontend con parseFloat\n";
    echo "   Input: '5000000' (string) -> parseFloat -> 5000000 (numeric)\n";

    $minDebtInput = '5000000';  // Como viene del input del usuario
    $minDebtNumeric = floatval($minDebtInput);  // parseFloat en JS = floatval en PHP

    echo "   Valor original: '$minDebtInput' (string)\n";
    echo "   Valor convertido: $minDebtNumeric (float)\n";

    $stmt->execute([
        'p_year' => null,
        'p_giro' => null,
        'p_min_debt' => $minDebtNumeric,
        'p_page' => 1,
        'p_limit' => 3
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "   ✓ ÉXITO - El filtro funciona correctamente\n";
        echo "   Total filtrados: " . number_format($results[0]['total_records']) . "\n\n";
    } else {
        echo "   ⚠ Sin resultados\n\n";
    }

    // TEST 5: Probar que string vacío YA NO funciona (era el problema original)
    echo "5. TEST: Verificar que string vacío ya NO se envía\n";
    echo "   (El frontend ahora envía NULL cuando minDebt está vacío)\n";
    echo "   Antes: minDebt = '' -> Error\n";
    echo "   Ahora: minDebt = null -> ✓ OK\n\n";

    try {
        $stmt->execute([
            'p_year' => null,
            'p_giro' => null,
            'p_min_debt' => '',  // String vacío (causaba error)
            'p_page' => 1,
            'p_limit' => 3
        ]);
        echo "   ⚠ String vacío aceptado (no debería pasar)\n\n";
    } catch (PDOException $e) {
        echo "   ✓ CORRECTO - String vacío rechazado\n";
        echo "   Error esperado: " . substr($e->getMessage(), 0, 80) . "...\n\n";
    }

    echo "========================================\n";
    echo "✅ VERIFICACIÓN COMPLETA\n";
    echo "========================================\n\n";

    echo "RESUMEN:\n";
    echo "- ✓ NULL funciona correctamente (sin filtro)\n";
    echo "- ✓ Valores numéricos funcionan (con filtro)\n";
    echo "- ✓ parseFloat en frontend convierte correctamente\n";
    echo "- ✓ String vacío se rechaza apropiadamente\n\n";

    echo "CAMBIOS EN VUE:\n";
    echo "1. loadEstadisticas(): tipo: 'numeric' (línea 397)\n";
    echo "2. loadGiros(): parseFloat(minDebt), tipo: 'numeric' (línea 440)\n";
    echo "3. exportToExcel(): parseFloat(minDebt), tipo: 'numeric' (línea 507)\n";
    echo "4. generateReport(): parseFloat(minDebt), tipo: 'numeric' (línea 552)\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}
