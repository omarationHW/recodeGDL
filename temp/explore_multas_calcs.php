<?php
// Explorar datos de multas para crear SP de prueba de cálculos
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== EXPLORANDO DATOS PARA PRUEBA DE CÁLCULOS ===\n\n";

    // Buscar tablas de multas con importes
    echo "--- Buscando tablas con multas e importes ---\n";
    $sql = "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename ILIKE '%multa%' OR tablename ILIKE '%recarg%' OR tablename ILIKE '%descuent%')
        AND schemaname IN ('comun', 'db_ingresos', 'public')
        ORDER BY schemaname, tablename
        LIMIT 15
    ";
    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";
    }

    // Obtener ejemplos de multas de comun.pagos
    echo "\n--- Ejemplos de pagos con multas ---\n";
    $sqlPagos = "
        SELECT
            cvepago,
            cvecuenta,
            importe,
            fecha,
            cveconcepto,
            folio
        FROM comun.pagos
        WHERE importe > 0
        AND fecha >= CURRENT_DATE - INTERVAL '1 year'
        ORDER BY importe DESC
        LIMIT 5
    ";
    $stmtPagos = $pdo->query($sqlPagos);
    $pagos = $stmtPagos->fetchAll(PDO::FETCH_ASSOC);

    foreach ($pagos as $idx => $p) {
        echo "\nEjemplo " . ($idx + 1) . ":\n";
        echo "  ID Pago: {$p['cvepago']}\n";
        echo "  Cuenta: {$p['cvecuenta']}\n";
        echo "  Importe: $" . number_format($p['importe'], 2) . "\n";
        echo "  Fecha: {$p['fecha']}\n";
        echo "  Concepto: {$p['cveconcepto']}\n";
        echo "  Folio: {$p['folio']}\n";
    }

    // Buscar tablas de tasas o porcentajes
    echo "\n\n--- Buscando tasas de recargos ---\n";
    $sqlTasas = "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename ILIKE '%tasa%' OR tablename ILIKE '%porcent%' OR tablename ILIKE '%factor%')
        AND schemaname IN ('comun', 'db_ingresos', 'public')
        ORDER BY schemaname, tablename
        LIMIT 10
    ";
    $stmtTasas = $pdo->query($sqlTasas);
    $tasas = $stmtTasas->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tasas as $t) {
        echo "{$t['schemaname']}.{$t['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
