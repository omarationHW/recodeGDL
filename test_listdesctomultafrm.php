<?php
// Script para probar el stored procedure recaudadora_listdesctomultafrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_listdesctomultafrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_listdesctomultafrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (todos los descuentos vigentes)
    echo "2. Probando sin filtro (todos los descuentos)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listdesctomultafrm(?::VARCHAR)");
    $stmt->execute(['']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Descuentos encontrados: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMEROS 3 DESCUENTOS ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $desc = $results[$i];
            echo "\n   DESCUENTO " . ($i + 1) . ":\n";
            echo "   ID Multa: {$desc['id_multa']}\n";
            echo "   Num Acta: {$desc['num_acta']}\n";
            echo "   Año Acta: {$desc['axo_acta']}\n";
            echo "   Contribuyente: " . substr($desc['contribuyente'], 0, 40) . "\n";
            echo "   Tipo Descuento: {$desc['tipo_descto']}\n";
            echo "   Valor Descuento: $" . number_format($desc['valor_descto'], 2) . "\n";
            echo "   Porcentaje: {$desc['porcentaje']}%\n";
            echo "   Total Original: $" . number_format($desc['total_original'], 2) . "\n";
            echo "   Total con Descto: $" . number_format($desc['total_con_descto'], 2) . "\n";
            echo "   Estado: {$desc['estado']}\n";
            echo "   Fecha: {$desc['fecha_movto']}\n";
            echo "   Folio: {$desc['folio']}\n";
        }
    }

    // 3. Probar con filtro por contribuyente
    echo "\n\n3. Probando con filtro 'MEZA' (contribuyente)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listdesctomultafrm(?::VARCHAR)");
    $stmt->execute(['MEZA']);
    $results_meza = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Descuentos encontrados: " . count($results_meza) . "\n";

    if (count($results_meza) > 0) {
        $desc = $results_meza[0];
        echo "\n   Ejemplo:\n";
        echo "   Contribuyente: {$desc['contribuyente']}\n";
        echo "   Acta: {$desc['num_acta']}/{$desc['axo_acta']}\n";
        echo "   Porcentaje: {$desc['porcentaje']}%\n";
        echo "   Total Original: $" . number_format($desc['total_original'], 2) . "\n";
        echo "   Total con Descto: $" . number_format($desc['total_con_descto'], 2) . "\n";
    }

    // 4. Probar con filtro por año
    echo "\n\n4. Probando con filtro '2024' (año)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listdesctomultafrm(?::VARCHAR)");
    $stmt->execute(['2024']);
    $results_2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Descuentos de 2024: " . count($results_2024) . "\n";

    // 5. Probar con filtro por estado
    echo "\n\n5. Probando con filtro 'VIGENTE' (estado)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listdesctomultafrm(?::VARCHAR)");
    $stmt->execute(['VIGENTE']);
    $results_vigente = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Descuentos vigentes: " . count($results_vigente) . "\n";

    // 6. Estadísticas generales
    echo "\n\n6. Estadísticas generales...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.descmultampal d
        WHERE d.estado = 'V'
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total descuentos vigentes en BD: " . number_format($total['total']) . "\n";

    // Ver distribución por tipo
    echo "\n   Distribución por tipo de descuento:\n";
    $stmt_tipos = $pdo->query("
        SELECT
            tipo_descto,
            COUNT(*) as total
        FROM publico.descmultampal
        WHERE estado = 'V'
        GROUP BY tipo_descto
        ORDER BY total DESC
    ");
    $tipos = $stmt_tipos->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        $tipo_nombre = $tipo['tipo_descto'] == 'P' ? 'Porcentaje' :
                      ($tipo['tipo_descto'] == 'M' ? 'Monto' :
                      ($tipo['tipo_descto'] == 'E' ? 'Especial' : $tipo['tipo_descto']));
        echo "   - {$tipo_nombre} ({$tipo['tipo_descto']}): " . number_format($tipo['total']) . "\n";
    }

    // 7. Ver formato JSON
    echo "\n\n7. Formato JSON para el frontend (primeros 2 registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listdesctomultafrm(?::VARCHAR) LIMIT 2");
    $stmt->execute(['']);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
