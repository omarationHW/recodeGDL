<?php
// Script para probar el stored procedure recaudadora_modif_masiva actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_modif_masiva...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_modif_masiva.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda básica
    echo "2. Probando búsqueda: Recaudadora 1, cuentas 5000-5200, estado ACTIVO...\n";

    $params_json = json_encode([
        'recaudadora' => 1,
        'folio_inicio' => 5000,
        'folio_fin' => 5200,
        'estado' => 'ACTIVO'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?::TEXT)");
    $stmt->execute([$params_json]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total encontrados: {$result['total_encontrados']}\n";
    echo "   Mensaje: {$result['mensaje']}\n";
    echo "   Detalles: " . $result['detalles'] . "\n\n";

    // 3. Obtener detalles de los requerimientos
    if ($result['total_encontrados'] > 0) {
        echo "3. Obteniendo detalles de los requerimientos...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva_detalles(?, ?, ?, ?)");
        $stmt->execute([1, 5000, 5200, 'ACTIVO']);
        $detalles = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Detalles obtenidos: " . count($detalles) . " registros\n\n";

        if (count($detalles) > 0) {
            echo "   === PRIMEROS 5 REQUERIMIENTOS ===\n";
            for ($i = 0; $i < min(5, count($detalles)); $i++) {
                $req = $detalles[$i];
                echo "\n   REQUERIMIENTO " . ($i + 1) . ":\n";
                echo "   Cuenta: {$req['cvecuenta']}\n";
                echo "   Recaudadora: {$req['recaudadora']}\n";
                echo "   Vigencia: {$req['vigencia']}\n";
                echo "   Total: $" . number_format($req['total'], 2) . "\n";
                echo "   Fecha: {$req['fecha_emision']}\n";
                echo "   Impuesto: $" . number_format($req['impuesto'], 2) . "\n";
                echo "   Recargos: $" . number_format($req['recargos'], 2) . "\n";
                echo "   Gastos: $" . number_format($req['gastos'], 2) . "\n";
                echo "   Multas: $" . number_format($req['multas'], 2) . "\n";
            }
        }
    }

    // 4. Probar con rango más amplio
    echo "\n\n4. Probando con rango más amplio: Recaudadora 3, cuentas 1-100000...\n";

    $params_json2 = json_encode([
        'recaudadora' => 3,
        'folio_inicio' => 1,
        'folio_fin' => 100000,
        'estado' => 'ACTIVO'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?::TEXT)");
    $stmt->execute([$params_json2]);
    $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total encontrados: {$result2['total_encontrados']}\n";
    echo "   Mensaje: {$result2['mensaje']}\n";

    // 5. Probar con estado CANCELADO
    echo "\n\n5. Probando con estado CANCELADO...\n";

    $params_json3 = json_encode([
        'recaudadora' => 1,
        'folio_inicio' => 1,
        'folio_fin' => 500000,
        'estado' => 'CANCELADO'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?::TEXT)");
    $stmt->execute([$params_json3]);
    $result3 = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total encontrados: {$result3['total_encontrados']}\n";
    echo "   Mensaje: {$result3['mensaje']}\n";

    // 6. Probar búsqueda sin resultados
    echo "\n\n6. Probando búsqueda sin resultados (rango vacío)...\n";

    $params_json4 = json_encode([
        'recaudadora' => 1,
        'folio_inicio' => 999999,
        'folio_fin' => 999999,
        'estado' => 'ACTIVO'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?::TEXT)");
    $stmt->execute([$params_json4]);
    $result4 = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total encontrados: {$result4['total_encontrados']}\n";
    echo "   Mensaje: {$result4['mensaje']}\n";

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.reqbfpredial
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total requerimientos en BD: " . number_format($total['total']) . "\n";

    $stmt_vigentes = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.reqbfpredial
        WHERE vigencia = 'V'
    ");
    $vigentes = $stmt_vigentes->fetch(PDO::FETCH_ASSOC);
    echo "   Requerimientos vigentes: " . number_format($vigentes['total']) . "\n";

    // Ver distribución por recaudadora
    echo "\n   Distribución por recaudadora (vigentes):\n";
    $stmt_rec = $pdo->query("
        SELECT
            recaud,
            COUNT(*) as total
        FROM public.reqbfpredial
        WHERE vigencia = 'V'
        GROUP BY recaud
        ORDER BY recaud
    ");
    $recauds = $stmt_rec->fetchAll(PDO::FETCH_ASSOC);
    foreach ($recauds as $rec) {
        echo "   - Recaudadora {$rec['recaud']}: " . number_format($rec['total']) . "\n";
    }

    // 8. Ver formato JSON del resultado
    echo "\n\n8. Formato JSON del resultado:\n";
    $params_json5 = json_encode([
        'recaudadora' => 1,
        'folio_inicio' => 5000,
        'folio_fin' => 5050,
        'estado' => 'ACTIVO'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?::TEXT)");
    $stmt->execute([$params_json5]);
    $result5 = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode($result5, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
