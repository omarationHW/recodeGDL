<?php
// Verificar estructura y datos de reqmultas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE publico.reqmultas ===\n\n";

    // 1. Ver todas las columnas
    echo "1. Estructura completa de publico.reqmultas:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'reqmultas'
        ORDER BY ordinal_position
    ");
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "   - {$col['column_name']} ({$col['data_type']}) - NULL: {$col['is_nullable']}\n";
    }

    // 2. Ejemplos de registros recientes
    echo "\n2. Ejemplos de registros recientes (primeros 5):\n";
    $stmt = $pdo->query("
        SELECT *
        FROM publico.reqmultas
        ORDER BY fecemi DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ejemplos as $i => $ej) {
        echo "\n   === REQUERIMIENTO " . ($i + 1) . " ===\n";
        foreach ($ej as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "   {$key}: {$value}\n";
            }
        }
    }

    // 3. Hacer JOIN con multas para obtener acta y contribuyente
    echo "\n\n3. JOIN con multas para obtener datos completos:\n";
    $stmt = $pdo->query("
        SELECT
            r.cvereq,
            r.folioreq,
            r.axoreq,
            r.recaud,
            r.tipo,
            r.fecemi,
            r.total,
            r.vigencia,
            m.num_lote,
            m.num_acta,
            m.axo_acta,
            m.contribuyente,
            m.domicilio,
            m.id_dependencia
        FROM publico.reqmultas r
        LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
        WHERE r.vigencia = 'V'
        ORDER BY r.fecemi DESC
        LIMIT 5
    ");
    $ejemplos_join = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($ejemplos_join) . "\n\n";

    if (count($ejemplos_join) > 0) {
        foreach ($ejemplos_join as $i => $ej) {
            echo "   === REQ " . ($i + 1) . " ===\n";
            echo "   Folio Req: {$ej['folioreq']}\n";
            echo "   Año Req: {$ej['axoreq']}\n";
            echo "   Tipo: {$ej['tipo']}\n";
            echo "   Recaud: {$ej['recaud']}\n";
            echo "   Num Acta: {$ej['num_acta']}\n";
            echo "   Año Acta: {$ej['axo_acta']}\n";
            echo "   Contribuyente: " . substr($ej['contribuyente'] ?? '', 0, 40) . "\n";
            echo "   Domicilio: " . substr($ej['domicilio'] ?? '', 0, 40) . "\n";
            echo "   Total: {$ej['total']}\n";
            echo "   Num Lote: {$ej['num_lote']}\n";
            echo "   Dependencia: {$ej['id_dependencia']}\n";
            echo "\n";
        }
    }

    // 4. Verificar tipo de documento
    echo "\n4. Verificar campo 'tipo' (tipo de documento):\n";
    $stmt = $pdo->query("
        SELECT tipo, COUNT(*) as total
        FROM publico.reqmultas
        GROUP BY tipo
        ORDER BY total DESC
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        $tipo_val = $tipo['tipo'] ?: '(NULL)';
        echo "   {$tipo_val}: " . number_format($tipo['total']) . "\n";
    }

    // 5. Estados de vigencia
    echo "\n5. Estados de vigencia:\n";
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

    // 6. Rango de fechas
    echo "\n6. Rango de fechas:\n";
    $stmt = $pdo->query("
        SELECT
            MIN(fecemi) as fecha_min,
            MAX(fecemi) as fecha_max,
            COUNT(*) as total
        FROM publico.reqmultas
    ");
    $rango = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Fecha mínima: {$rango['fecha_min']}\n";
    echo "   Fecha máxima: {$rango['fecha_max']}\n";
    echo "   Total registros: " . number_format($rango['total']) . "\n";

    // 7. Verificar recaudadoras
    echo "\n7. Recaudadoras:\n";
    $stmt = $pdo->query("
        SELECT recaud, COUNT(*) as total
        FROM publico.reqmultas
        GROUP BY recaud
        ORDER BY recaud
        LIMIT 10
    ");
    $recauds = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($recauds as $rec) {
        echo "   Recaudadora {$rec['recaud']}: " . number_format($rec['total']) . "\n";
    }

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
