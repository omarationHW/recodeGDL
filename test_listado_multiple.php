<?php
// Script para probar el stored procedure recaudadora_listado_multiple actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_listado_multiple...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_listado_multiple.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (pagos recientes)
    echo "2. Probando sin filtro (pagos más recientes)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['', 0, 10]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos encontrados: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMEROS 3 PAGOS ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $pago = $results[$i];
            echo "\n   PAGO " . ($i + 1) . ":\n";
            echo "   ID: {$pago['id']}\n";
            echo "   Folio: {$pago['folio']}\n";
            echo "   Tipo: {$pago['tipo_movimiento']}\n";
            echo "   Cuenta: {$pago['clave_cuenta']}\n";
            echo "   Contribuyente: {$pago['contribuyente']}\n";
            echo "   Concepto: {$pago['concepto']}\n";
            echo "   Descripción: {$pago['descripcion']}\n";
            echo "   Monto: $" . number_format($pago['monto'], 2) . "\n";
            echo "   Fecha: {$pago['fecha_movimiento']}\n";
            echo "   Estado: {$pago['estado']}\n";
            echo "   Usuario: {$pago['usuario']}\n";
            echo "   Recaudadora: {$pago['recaudadora']}\n";
        }
    }

    // 3. Probar con filtro por concepto
    echo "\n\n3. Probando con filtro 'PREDIAL' (concepto)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['PREDIAL', 0, 10]);
    $results_predial = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos de PREDIAL: " . count($results_predial) . "\n";

    if (count($results_predial) > 0) {
        $pago = $results_predial[0];
        echo "\n   Ejemplo:\n";
        echo "   Folio: {$pago['folio']}\n";
        echo "   Concepto: {$pago['concepto']}\n";
        echo "   Monto: $" . number_format($pago['monto'], 2) . "\n";
        echo "   Estado: {$pago['estado']}\n";
    }

    // 4. Probar con filtro por folio
    echo "\n\n4. Probando con filtro por folio '5226163'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['5226163', 0, 10]);
    $results_folio = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos con folio '5226163': " . count($results_folio) . "\n";

    if (count($results_folio) > 0) {
        $pago = $results_folio[0];
        echo "\n   Detalle:\n";
        echo "   Folio: {$pago['folio']}\n";
        echo "   Cuenta: {$pago['clave_cuenta']}\n";
        echo "   Concepto: {$pago['concepto']}\n";
        echo "   Monto: $" . number_format($pago['monto'], 2) . "\n";
    }

    // 5. Probar con filtro por estado
    echo "\n\n5. Probando con filtro 'cancelado' (estado)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['cancelado', 0, 10]);
    $results_cancelado = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos cancelados: " . count($results_cancelado) . "\n";

    if (count($results_cancelado) > 0) {
        $pago = $results_cancelado[0];
        echo "\n   Ejemplo:\n";
        echo "   Folio: {$pago['folio']}\n";
        echo "   Estado: {$pago['estado']}\n";
        echo "   Monto: $" . number_format($pago['monto'], 2) . "\n";
    }

    // 6. Probar paginación
    echo "\n\n6. Probando paginación (offset=10, limit=5)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['', 10, 5]);
    $results_page2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos en página 2: " . count($results_page2) . "\n";

    if (count($results_page2) > 0) {
        $pago = $results_page2[0];
        echo "\n   Ejemplo:\n";
        echo "   Folio: {$pago['folio']}\n";
        echo "   Concepto: {$pago['concepto']}\n";
        echo "   Fecha: {$pago['fecha_movimiento']}\n";
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.pagos
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total pagos en BD: " . number_format($total['total']) . "\n";

    $stmt_activos = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.pagos
        WHERE cvecanc IS NULL
    ");
    $activos = $stmt_activos->fetch(PDO::FETCH_ASSOC);
    echo "   Pagos activos: " . number_format($activos['total']) . "\n";

    $stmt_cancelados = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.pagos
        WHERE cvecanc IS NOT NULL
    ");
    $cancelados = $stmt_cancelados->fetch(PDO::FETCH_ASSOC);
    echo "   Pagos cancelados: " . number_format($cancelados['total']) . "\n";

    // Ver distribución por concepto (top 5)
    echo "\n   Top 5 conceptos:\n";
    $stmt_conceptos = $pdo->query("
        SELECT
            c.descripcion,
            c.ncorto,
            COUNT(*) as total
        FROM publico.pagos p
        LEFT JOIN publico.c_conceptos c ON p.cveconcepto = c.cveconcepto
        GROUP BY c.descripcion, c.ncorto
        ORDER BY total DESC
        LIMIT 5
    ");
    $conceptos = $stmt_conceptos->fetchAll(PDO::FETCH_ASSOC);
    foreach ($conceptos as $concepto) {
        echo "   - " . trim($concepto['descripcion']) . " ({$concepto['ncorto']}): " . number_format($concepto['total']) . "\n";
    }

    // 8. Ver formato JSON
    echo "\n\n8. Formato JSON para el frontend (primeros 2 registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['', 0, 2]);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
