<?php
// Script para verificar los datos de cheques disponibles

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE DATOS DE CHEQUES ===\n\n";

    // 1. Total de registros en cheqpag
    echo "1. Total de registros en public.cheqpag:\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.cheqpag");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total: " . number_format($total['total']) . " registros\n\n";

    // 2. Ejemplos de cheqpag
    echo "2. Ejemplos de registros en public.cheqpag:\n";
    $stmt = $pdo->query("SELECT * FROM public.cheqpag LIMIT 5");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($ejemplos as $ej) {
        echo "   cvepago={$ej['cvepago']}, banco={$ej['cvebanco']}, cheque={$ej['numcheq']}, cuenta={$ej['ncta']}, importe={$ej['importe']}\n";
    }

    // 3. Verificar si existen esos cvepago en la tabla pagos
    echo "\n3. Verificar si los cvepago de cheqpag existen en publico.pagos:\n";
    $stmt = $pdo->query("
        SELECT p.cvepago, p.fecha, p.caja, p.folio, p.recaud, p.importe
        FROM publico.pagos p
        INNER JOIN public.cheqpag c ON p.cvepago = c.cvepago
        LIMIT 5
    ");
    $ejemplos_join = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($ejemplos_join) > 0) {
        foreach ($ejemplos_join as $ej) {
            echo "   cvepago={$ej['cvepago']}, fecha={$ej['fecha']}, caja={$ej['caja']}, folio={$ej['folio']}, recaud={$ej['recaud']}\n";
        }
    } else {
        echo "   ❌ No hay registros que hagan JOIN entre cheqpag y pagos\n";
    }

    // 4. Contar total de coincidencias
    echo "\n4. Total de coincidencias entre cheqpag y pagos:\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.pagos p
        INNER JOIN public.cheqpag c ON p.cvepago = c.cvepago
    ");
    $total_join = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total: " . number_format($total_join['total']) . " registros\n\n";

    // 5. Verificar fechas en pagos con cheques
    echo "5. Rango de fechas de pagos con cheques:\n";
    $stmt = $pdo->query("
        SELECT
            MIN(p.fecha) as fecha_minima,
            MAX(p.fecha) as fecha_maxima
        FROM publico.pagos p
        INNER JOIN public.cheqpag c ON p.cvepago = c.cvepago
    ");
    $rango = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Fecha mínima: {$rango['fecha_minima']}\n";
    echo "   Fecha máxima: {$rango['fecha_maxima']}\n\n";

    // 6. Contar pagos cancelados vs no cancelados
    echo "6. Pagos cancelados vs no cancelados con cheque:\n";
    $stmt = $pdo->query("
        SELECT
            COUNT(CASE WHEN p.cvecanc IS NULL THEN 1 END) as no_cancelados,
            COUNT(CASE WHEN p.cvecanc IS NOT NULL THEN 1 END) as cancelados
        FROM publico.pagos p
        INNER JOIN public.cheqpag c ON p.cvepago = c.cvepago
    ");
    $estado = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   No cancelados: " . number_format($estado['no_cancelados']) . "\n";
    echo "   Cancelados: " . number_format($estado['cancelados']) . "\n\n";

    echo "✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
