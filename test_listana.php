<?php
// Script para probar el stored procedure recaudadora_listana actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_listana...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_listana.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (primeros registros)
    echo "2. Probando sin filtro (listado analítico general)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listana(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['', 0, 10]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "   Total de registros en BD: " . number_format($results[0]['total_count']) . "\n\n";
    }

    if (count($results) > 0) {
        echo "   === PRIMEROS 3 REGISTROS ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $reg = $results[$i];
            echo "\n   REGISTRO " . ($i + 1) . ":\n";
            echo "   Cuenta: {$reg['clave_cuenta']}\n";
            echo "   Contribuyente: {$reg['contribuyente']}\n";
            echo "   Concepto: {$reg['concepto']}\n";
            echo "   Impuesto: $" . number_format($reg['impuesto'], 2) . "\n";
            echo "   Recargos: $" . number_format($reg['recargos'], 2) . "\n";
            echo "   Multas: $" . number_format($reg['multas'], 2) . "\n";
            echo "   Actualización: $" . number_format($reg['actualizacion'], 2) . "\n";
            echo "   Total: $" . number_format($reg['total'], 2) . "\n";
            echo "   Estado: {$reg['estado']}\n";
            echo "   Fecha Emisión: {$reg['fecha_emision']}\n";
        }
    }

    // 3. Probar con paginación (página 2)
    echo "\n\n3. Probando con paginación (offset=10, limit=5)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listana(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['', 10, 5]);
    $results_page2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros en página 2: " . count($results_page2) . "\n";

    if (count($results_page2) > 0) {
        $reg = $results_page2[0];
        echo "\n   Ejemplo:\n";
        echo "   Cuenta: {$reg['clave_cuenta']}\n";
        echo "   Concepto: {$reg['concepto']}\n";
        echo "   Total: $" . number_format($reg['total'], 2) . "\n";
        echo "   Estado: {$reg['estado']}\n";
    }

    // 4. Probar con filtro por cuenta
    echo "\n\n4. Probando con filtro por cuenta '100'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listana(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['100', 0, 10]);
    $results_filtro = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros con cuenta '100': " . count($results_filtro) . "\n";

    if (count($results_filtro) > 0) {
        $reg = $results_filtro[0];
        echo "\n   Ejemplo:\n";
        echo "   Cuenta: {$reg['clave_cuenta']}\n";
        echo "   Contribuyente: {$reg['contribuyente']}\n";
        echo "   Concepto: {$reg['concepto']}\n";
        echo "   Total: $" . number_format($reg['total'], 2) . "\n";
    }

    // 5. Estadísticas generales
    echo "\n\n5. Estadísticas generales...\n";

    $stmt_req = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.reqbfpredial
    ");
    $total_req = $stmt_req->fetch(PDO::FETCH_ASSOC);
    echo "   Total requerimientos prediales: " . number_format($total_req['total']) . "\n";

    $stmt_det = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.detreqbfpredial
    ");
    $total_det = $stmt_det->fetch(PDO::FETCH_ASSOC);
    echo "   Total detalles por año: " . number_format($total_det['total']) . "\n";

    // Ver distribución por estado
    echo "\n   Distribución por estado:\n";
    $stmt_estados = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as total
        FROM public.reqbfpredial
        WHERE vigencia IS NOT NULL
        GROUP BY vigencia
        ORDER BY total DESC
    ");
    $estados = $stmt_estados->fetchAll(PDO::FETCH_ASSOC);
    foreach ($estados as $estado) {
        $estado_nombre = $estado['vigencia'] == 'V' ? 'Vigente' :
                        ($estado['vigencia'] == 'C' ? 'Cancelado' :
                        ($estado['vigencia'] == 'P' ? 'Pagado' :
                        ($estado['vigencia'] == 'X' ? 'Expirado' :
                        ($estado['vigencia'] == 'i' ? 'Incompleto' : $estado['vigencia']))));
        echo "   - {$estado_nombre} ({$estado['vigencia']}): " . number_format($estado['total']) . "\n";
    }

    // 6. Ver formato JSON
    echo "\n\n6. Formato JSON para el frontend (primeros 2 registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listana(?::VARCHAR, ?::INTEGER, ?::INTEGER)");
    $stmt->execute(['', 0, 2]);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Remover total_count para JSON más limpio
    foreach ($result_json as &$row) {
        $total_count = $row['total_count'];
        unset($row['total_count']);
    }

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    echo "\n\n   Total Count: " . number_format($total_count) . "\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
