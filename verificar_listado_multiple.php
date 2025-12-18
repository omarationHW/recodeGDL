<?php
// Verificar estructura para listado múltiple

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN PARA LISTADO MÚLTIPLE ===\n\n";

    // 1. Ver estructura de pagos con conceptos
    echo "1. JOIN de pagos con conceptos:\n";
    $stmt = $pdo->query("
        SELECT
            p.cvepago,
            p.folio,
            p.cvecuenta,
            p.recaud,
            p.fecha,
            p.importe,
            p.cajero,
            p.cvecanc,
            c.descripcion as concepto,
            c.ncorto
        FROM publico.pagos p
        LEFT JOIN publico.c_conceptos c ON p.cveconcepto = c.cveconcepto
        WHERE p.fecha >= '2024-01-01'
        LIMIT 5
    ");

    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($resultados as $i => $row) {
        echo "   Registro " . ($i + 1) . ":\n";
        echo "     Folio: {$row['folio']}\n";
        echo "     Cuenta: {$row['cvecuenta']}\n";
        echo "     Recaudadora: {$row['recaud']}\n";
        echo "     Fecha: {$row['fecha']}\n";
        echo "     Importe: $" . number_format($row['importe'], 2) . "\n";
        echo "     Cajero: {$row['cajero']}\n";
        echo "     Concepto: {$row['concepto']}\n";
        echo "     Corto: {$row['ncorto']}\n";
        echo "     Estado: " . ($row['cvecanc'] ? 'Cancelado' : 'Activo') . "\n\n";
    }

    // 2. Ver todos los conceptos disponibles
    echo "\n2. Conceptos disponibles:\n";
    $stmt_conceptos = $pdo->query("
        SELECT cveconcepto, descripcion, ncorto
        FROM publico.c_conceptos
        ORDER BY cveconcepto
    ");

    foreach ($stmt_conceptos->fetchAll(PDO::FETCH_ASSOC) as $concepto) {
        echo "   [{$concepto['cveconcepto']}] {$concepto['descripcion']} ({$concepto['ncorto']})\n";
    }

    // 3. Mapeo de campos para listado múltiple
    echo "\n\n3. Mapeo de campos:\n";
    echo "   id → cvepago\n";
    echo "   folio → folio\n";
    echo "   tipo_movimiento → 'Pago' (todos son pagos)\n";
    echo "   clave_cuenta → cvecuenta\n";
    echo "   contribuyente → 'Cuenta ' || cvecuenta (no hay nombre directo)\n";
    echo "   concepto → c_conceptos.descripcion\n";
    echo "   descripcion → c_conceptos.ncorto\n";
    echo "   monto → importe\n";
    echo "   fecha_movimiento → fecha\n";
    echo "   estado → IF cvecanc IS NULL THEN 'Activo' ELSE 'Cancelado'\n";
    echo "   usuario → cajero\n";
    echo "   recaudadora → recaud\n";

    // 4. Estadísticas
    echo "\n\n4. Estadísticas:\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM publico.pagos");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total pagos: " . number_format($total['total']) . "\n";

    $stmt_activos = $pdo->query("SELECT COUNT(*) as total FROM publico.pagos WHERE cvecanc IS NULL");
    $activos = $stmt_activos->fetch(PDO::FETCH_ASSOC);
    echo "   Pagos activos: " . number_format($activos['total']) . "\n";

    $stmt_cancelados = $pdo->query("SELECT COUNT(*) as total FROM publico.pagos WHERE cvecanc IS NOT NULL");
    $cancelados = $stmt_cancelados->fetch(PDO::FETCH_ASSOC);
    echo "   Pagos cancelados: " . number_format($cancelados['total']) . "\n";

    // 5. Pagos recientes (2024-2025)
    echo "\n\n5. Pagos recientes (2024-2025):\n";
    $stmt_recientes = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.pagos
        WHERE fecha >= '2024-01-01'
    ");
    $recientes = $stmt_recientes->fetch(PDO::FETCH_ASSOC);
    echo "   Pagos desde 2024: " . number_format($recientes['total']) . "\n";

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
