<?php
// Script para probar el stored procedure recaudadora_listareq actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_listareq...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_listareq.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (requerimientos recientes)
    echo "2. Probando sin filtro (requerimientos recientes)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?::VARCHAR)");
    $stmt->execute(['']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Requerimientos encontrados: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMEROS 3 REQUERIMIENTOS ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $req = $results[$i];
            echo "\n   REQUERIMIENTO " . ($i + 1) . ":\n";
            echo "   Folio: {$req['folio']}\n";
            echo "   Clave Cuenta: {$req['clave_cuenta']}\n";
            echo "   Ejercicio: {$req['ejercicio']}\n";
            echo "   Contribuyente: {$req['contribuyente']}\n";
            echo "   Domicilio: " . substr($req['domicilio'], 0, 40) . "\n";
            echo "   Concepto: {$req['concepto']}\n";
            echo "   Monto: $" . number_format($req['monto'], 2) . "\n";
            echo "   Fecha Emisión: {$req['fecha_emision']}\n";
            echo "   Estado: {$req['estado']}\n";
            echo "   Observaciones: " . substr($req['observaciones'] ?? '', 0, 40) . "\n";
        }
    }

    // 3. Probar con búsqueda por contribuyente
    echo "\n\n3. Probando con filtro 'FLORES' (contribuyente)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?::VARCHAR)");
    $stmt->execute(['FLORES']);
    $results_flores = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Requerimientos de 'FLORES': " . count($results_flores) . "\n";

    if (count($results_flores) > 0) {
        $req = $results_flores[0];
        echo "\n   Ejemplo:\n";
        echo "   Folio: {$req['folio']}\n";
        echo "   Contribuyente: {$req['contribuyente']}\n";
        echo "   Concepto: {$req['concepto']}\n";
        echo "   Estado: {$req['estado']}\n";
        echo "   Monto: $" . number_format($req['monto'], 2) . "\n";
    }

    // 4. Probar con búsqueda por número de acta
    echo "\n\n4. Probando con filtro '2042' (número de acta)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?::VARCHAR)");
    $stmt->execute(['2042']);
    $results_acta = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Requerimientos con acta '2042': " . count($results_acta) . "\n";

    if (count($results_acta) > 0) {
        $req = $results_acta[0];
        echo "\n   Ejemplo:\n";
        echo "   Folio: {$req['folio']}\n";
        echo "   Clave Cuenta: {$req['clave_cuenta']}\n";
        echo "   Contribuyente: {$req['contribuyente']}\n";
        echo "   Concepto: {$req['concepto']}\n";
    }

    // 5. Probar con búsqueda por folio
    echo "\n\n5. Probando con filtro '146289' (folio)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?::VARCHAR)");
    $stmt->execute(['146289']);
    $results_folio = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Requerimientos con folio '146289': " . count($results_folio) . "\n";

    if (count($results_folio) > 0) {
        $req = $results_folio[0];
        echo "\n   Ejemplo:\n";
        echo "   Folio: {$req['folio']}\n";
        echo "   Clave Cuenta: {$req['clave_cuenta']}\n";
        echo "   Contribuyente: {$req['contribuyente']}\n";
        echo "   Estado: {$req['estado']}\n";
    }

    // 6. Estadísticas generales
    echo "\n\n6. Estadísticas generales...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.reqmultas
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total requerimientos en BD: " . number_format($total['total']) . "\n";

    // Ver distribución por tipo
    echo "\n   Distribución por tipo (concepto):\n";
    $stmt_tipos = $pdo->query("
        SELECT
            tipo,
            COUNT(*) as total
        FROM publico.reqmultas
        GROUP BY tipo
        ORDER BY total DESC
    ");
    $tipos = $stmt_tipos->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        $tipo_nombre = $tipo['tipo'] == 'N' ? 'Normal' :
                      ($tipo['tipo'] == 'R' ? 'Requerimiento' :
                      ($tipo['tipo'] == 'S' ? 'Especial' :
                      ($tipo['tipo'] == 'D' ? 'Diferencia' : $tipo['tipo'])));
        echo "   - {$tipo_nombre}: " . number_format($tipo['total']) . "\n";
    }

    // Ver distribución por estado
    echo "\n   Distribución por estado:\n";
    $stmt_estados = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as total
        FROM publico.reqmultas
        GROUP BY vigencia
        ORDER BY total DESC
    ");
    $estados = $stmt_estados->fetchAll(PDO::FETCH_ASSOC);
    foreach ($estados as $estado) {
        $estado_nombre = $estado['vigencia'] == 'V' ? 'Vigente' :
                        ($estado['vigencia'] == 'C' ? 'Cancelado' :
                        ($estado['vigencia'] == 'P' ? 'Pagado' : $estado['vigencia']));
        echo "   - {$estado_nombre}: " . number_format($estado['total']) . "\n";
    }

    // 7. Ver formato JSON
    echo "\n\n7. Formato JSON para el frontend (primeros 2 registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?::VARCHAR) LIMIT 2");
    $stmt->execute(['']);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
