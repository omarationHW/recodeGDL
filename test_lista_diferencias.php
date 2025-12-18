<?php
// Script para probar el stored procedure recaudadora_lista_diferencias actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_lista_diferencias...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_lista_diferencias.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (todas las diferencias recientes)
    echo "2. Probando sin filtro (diferencias recientes)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?::VARCHAR)");
    $stmt->execute(['']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Diferencias encontradas: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMERAS 3 DIFERENCIAS ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $dif = $results[$i];
            echo "\n   DIFERENCIA " . ($i + 1) . ":\n";
            echo "   ID: {$dif['id_diferencia']}\n";
            echo "   Tipo Registro: {$dif['tipo_registro']}\n";
            echo "   Campo Afectado: {$dif['campo_afectado']}\n";
            echo "   Valor Sistema: {$dif['valor_sistema']}\n";
            echo "   Valor Registrado: {$dif['valor_registrado']}\n";
            echo "   Diferencia Monto: $" . number_format($dif['diferencia_monto'], 2) . "\n";
            echo "   Folio: {$dif['folio']}\n";
            echo "   Fecha: {$dif['fecha_deteccion']}\n";
            echo "   Estado: {$dif['estado']}\n";
            echo "   Responsable: {$dif['responsable']}\n";
        }
    }

    // 3. Probar con filtro por tipo
    echo "\n\n3. Probando con filtro 'PREDIAL' (tipo)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?::VARCHAR)");
    $stmt->execute(['PREDIAL']);
    $results_predial = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Diferencias tipo PREDIAL: " . count($results_predial) . "\n";

    if (count($results_predial) > 0) {
        $dif = $results_predial[0];
        echo "\n   Ejemplo:\n";
        echo "   Tipo: {$dif['tipo_registro']}\n";
        echo "   Campo: {$dif['campo_afectado']}\n";
        echo "   Diferencia: $" . number_format($dif['diferencia_monto'], 2) . "\n";
        echo "   Estado: {$dif['estado']}\n";
    }

    // 4. Probar con filtro por campo afectado
    echo "\n\n4. Probando con filtro 'RECARGOS' (campo)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?::VARCHAR)");
    $stmt->execute(['RECARGOS']);
    $results_recargos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Diferencias en RECARGOS: " . count($results_recargos) . "\n";

    // 5. Probar con filtro por estado
    echo "\n\n5. Probando con filtro 'PENDIENTE' (estado)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?::VARCHAR)");
    $stmt->execute(['PENDIENTE']);
    $results_pendiente = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Diferencias pendientes: " . count($results_pendiente) . "\n";

    // 6. Probar con filtro por usuario
    echo "\n\n6. Probando con filtro 'lguevara' (usuario)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?::VARCHAR)");
    $stmt->execute(['lguevara']);
    $results_usuario = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Diferencias de usuario lguevara: " . count($results_usuario) . "\n";

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.diferencias_glosa
        WHERE vigencia = 'P'
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total diferencias pendientes en BD: " . number_format($total['total']) . "\n";

    // Ver distribución por tipo
    echo "\n   Distribución por tipo:\n";
    $stmt_tipos = $pdo->query("
        SELECT
            tipo_dif,
            COUNT(*) as total
        FROM public.diferencias_glosa
        GROUP BY tipo_dif
        ORDER BY total DESC
    ");
    $tipos = $stmt_tipos->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        $tipo_nombre = $tipo['tipo_dif'] == 'P' ? 'PREDIAL' :
                      ($tipo['tipo_dif'] == 'N' ? 'NORMAL' : $tipo['tipo_dif']);
        echo "   - {$tipo_nombre}: " . number_format($tipo['total']) . "\n";
    }

    // Ver distribución por campo afectado
    echo "\n   Distribución por campo afectado:\n";
    $stmt_campos = $pdo->query("
        SELECT
            diferen,
            COUNT(*) as total
        FROM public.diferencias_glosa
        GROUP BY diferen
        ORDER BY total DESC
    ");
    $campos = $stmt_campos->fetchAll(PDO::FETCH_ASSOC);
    foreach ($campos as $campo) {
        $campo_nombre = $campo['diferen'] == 'I' ? 'IMPUESTO BASE' :
                       ($campo['diferen'] == 'R' ? 'RECARGOS' :
                       ($campo['diferen'] == 'M' ? 'MULTAS' : $campo['diferen']));
        echo "   - {$campo_nombre}: " . number_format($campo['total']) . "\n";
    }

    // 8. Ver formato JSON
    echo "\n\n8. Formato JSON para el frontend (primeros 2 registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?::VARCHAR) LIMIT 2");
    $stmt->execute(['']);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
