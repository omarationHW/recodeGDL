<?php
// Verificar estructura de reqmultas para listareq.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE publico.reqmultas PARA listareq.vue ===\n\n";

    // 1. Verificar campos necesarios
    echo "1. Campos de publico.reqmultas:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'reqmultas'
        ORDER BY ordinal_position
    ");
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "   - {$col['column_name']} ({$col['data_type']})\n";
    }

    // 2. Mapeo de campos necesarios
    echo "\n2. Mapeo de campos requeridos:\n";
    echo "   folio → folioreq\n";
    echo "   clave_cuenta → num_acta (de multas via id_multa)\n";
    echo "   ejercicio → axoreq\n";
    echo "   contribuyente → contribuyente (de multas via id_multa)\n";
    echo "   domicilio → domicilio (de multas via id_multa)\n";
    echo "   concepto → tipo (N/R/S/D)\n";
    echo "   monto → total\n";
    echo "   fecha_emision → fecemi\n";
    echo "   estado → vigencia (V/C/P)\n";
    echo "   observaciones → obs\n";

    // 3. JOIN con multas para obtener datos completos
    echo "\n3. Ejemplos de requerimientos con JOIN a multas:\n";
    $stmt = $pdo->query("
        SELECT
            r.folioreq,
            r.axoreq,
            r.tipo,
            r.fecemi,
            r.total,
            r.vigencia,
            r.obs,
            m.num_acta,
            m.axo_acta,
            m.contribuyente,
            m.domicilio
        FROM publico.reqmultas r
        LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
        WHERE r.vigencia = 'V'
        ORDER BY r.fecemi DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($ejemplos) . "\n\n";

    foreach ($ejemplos as $i => $ej) {
        echo "   === REQUERIMIENTO " . ($i + 1) . " ===\n";
        echo "   Folio: {$ej['folioreq']}\n";
        echo "   Ejercicio: {$ej['axoreq']}\n";
        echo "   Tipo: {$ej['tipo']}\n";
        echo "   Fecha Emisión: {$ej['fecemi']}\n";
        echo "   Total: $" . number_format($ej['total'], 2) . "\n";
        echo "   Estado: {$ej['vigencia']}\n";
        echo "   Num Acta: " . ($ej['num_acta'] ?? 'N/A') . " / Año: " . ($ej['axo_acta'] ?? 'N/A') . "\n";
        echo "   Contribuyente: " . substr($ej['contribuyente'] ?? 'N/A', 0, 40) . "\n";
        echo "   Domicilio: " . substr($ej['domicilio'] ?? 'N/A', 0, 40) . "\n";
        echo "   Observaciones: " . substr($ej['obs'] ?? '', 0, 40) . "\n";
        echo "\n";
    }

    // 4. Estadísticas por tipo
    echo "\n4. Distribución por tipo de requerimiento:\n";
    $stmt = $pdo->query("
        SELECT tipo, COUNT(*) as total
        FROM publico.reqmultas
        GROUP BY tipo
        ORDER BY total DESC
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        $tipo_val = $tipo['tipo'] ?: '(NULL)';
        $tipo_nombre = $tipo_val == 'N' ? 'Normal' :
                      ($tipo_val == 'R' ? 'Requerimiento' :
                      ($tipo_val == 'S' ? 'Especial' :
                      ($tipo_val == 'D' ? 'Diferencia' : $tipo_val)));
        echo "   {$tipo_nombre} ({$tipo_val}): " . number_format($tipo['total']) . "\n";
    }

    // 5. Estadísticas por estado
    echo "\n5. Distribución por estado:\n";
    $stmt = $pdo->query("
        SELECT vigencia, COUNT(*) as total
        FROM publico.reqmultas
        GROUP BY vigencia
        ORDER BY total DESC
    ");
    $estados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($estados as $est) {
        $est_val = $est['vigencia'] ?: '(NULL)';
        $est_nombre = $est_val == 'V' ? 'Vigente' :
                     ($est_val == 'C' ? 'Cancelado' :
                     ($est_val == 'P' ? 'Pagado' : $est_val));
        echo "   {$est_nombre} ({$est_val}): " . number_format($est['total']) . "\n";
    }

    // 6. Verificar búsqueda por acta
    echo "\n6. Prueba de búsqueda por número de acta '2042':\n";
    $stmt = $pdo->prepare("
        SELECT
            r.folioreq,
            r.tipo,
            r.total,
            m.num_acta,
            m.axo_acta,
            m.contribuyente
        FROM publico.reqmultas r
        LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
        WHERE m.num_acta::TEXT ILIKE '%2042%'
        LIMIT 3
    ");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($resultados) . "\n";
    foreach ($resultados as $res) {
        echo "   - Folio: {$res['folioreq']}, Acta: {$res['num_acta']}/{$res['axo_acta']}, Tipo: {$res['tipo']}\n";
    }

    // 7. Verificar búsqueda por contribuyente
    echo "\n7. Prueba de búsqueda por contribuyente 'FLORES':\n";
    $stmt = $pdo->prepare("
        SELECT
            r.folioreq,
            r.tipo,
            r.total,
            m.contribuyente
        FROM publico.reqmultas r
        LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
        WHERE m.contribuyente ILIKE '%FLORES%'
        LIMIT 3
    ");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($resultados) . "\n";
    foreach ($resultados as $res) {
        echo "   - Folio: {$res['folioreq']}, Contribuyente: " . substr($res['contribuyente'], 0, 40) . "\n";
    }

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
