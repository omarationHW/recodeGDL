<?php
// Script para verificar la tabla auditoria

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver estructura completa
    echo "=== ESTRUCTURA DE public.auditoria ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'auditoria'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Ver registros de ejemplo
    echo "\n\n=== REGISTROS DE EJEMPLO (primeros 5) ===\n\n";

    $stmt = $pdo->query("SELECT * FROM public.auditoria LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  {$key}: " . (is_null($value) ? 'NULL' : substr($value, 0, 80)) . "\n";
        }
        echo "\n";
    }

    // Estadísticas por cvectaapl
    echo "=== ESTADÍSTICAS POR CVECTAAPL (Top 20) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            cvectaapl,
            COUNT(*) as num_movimientos,
            SUM(monto) as suma_total
        FROM public.auditoria
        WHERE cvectaapl IS NOT NULL
        GROUP BY cvectaapl
        ORDER BY num_movimientos DESC
        LIMIT 20
    ");

    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "  cvectaapl: {$stat['cvectaapl']} - {$stat['num_movimientos']} movimientos - \$" . number_format($stat['suma_total'], 2) . "\n";
    }

    // Ver información general
    echo "\n\n=== INFORMACIÓN GENERAL ===\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(DISTINCT cvectaapl) as cuentas_diferentes,
            COUNT(DISTINCT cvepago) as pagos_diferentes,
            MIN(axopago) as anio_minimo,
            MAX(axopago) as anio_maximo
        FROM public.auditoria
        WHERE axopago IS NOT NULL
    ");

    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "  Cuentas aplicación diferentes: {$info['cuentas_diferentes']}\n";
    echo "  Pagos diferentes: {$info['pagos_diferentes']}\n";
    echo "  Año mínimo: {$info['anio_minimo']}\n";
    echo "  Año máximo: {$info['anio_maximo']}\n";

    echo "\n\n=== TOTAL ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.auditoria");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: " . number_format($total['total']) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
