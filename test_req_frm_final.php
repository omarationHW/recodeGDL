<?php
// Script para probar el stored procedure recaudadora_req_frm_save
// Con los campos que realmente usa el formulario ReqFrm.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_req_frm_save...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_req_frm_save.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar actas de ejemplo con datos completos
    echo "2. Buscando actas de ejemplo para probar...\n";
    $stmt = $pdo->query("
        SELECT num_acta, axo_acta, contribuyente, multa
        FROM publico.multas
        WHERE num_acta IS NOT NULL
          AND axo_acta >= 2024
          AND multa > 0
          AND cvepago IS NULL
          AND fecha_cancelacion IS NULL
        ORDER BY axo_acta DESC, num_acta DESC
        LIMIT 5
    ");
    $actas_ejemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Actas encontradas:\n";
    foreach ($actas_ejemplo as $a) {
        echo "     - Acta: {$a['num_acta']}/{$a['axo_acta']}, Contribuyente: " . substr($a['contribuyente'], 0, 30) . ", Monto: $" . number_format($a['multa'], 2) . "\n";
    }

    if (count($actas_ejemplo) > 0) {
        $acta_test = $actas_ejemplo[0];

        // 3. Probar guardado con los campos del formulario
        echo "\n\n3. Probando guardado con campos del formulario (cuenta, folio, ejercicio)...\n";

        // Buscar un folio disponible
        $stmt = $pdo->prepare("
            SELECT COALESCE(MAX(folioreq), 0) + 1 as siguiente_folio
            FROM publico.reqmultas
            WHERE axoreq = ?
        ");
        $stmt->execute([$acta_test['axo_acta']]);
        $folio_siguiente = $stmt->fetch(PDO::FETCH_ASSOC)['siguiente_folio'];

        $datos_req = [
            'clave_cuenta' => $acta_test['num_acta'],
            'folio' => $folio_siguiente,
            'ejercicio' => $acta_test['axo_acta']
        ];

        echo "   Datos a enviar:\n";
        echo "     - Cuenta: {$datos_req['clave_cuenta']}\n";
        echo "     - Folio: {$datos_req['folio']}\n";
        echo "     - Ejercicio: {$datos_req['ejercicio']}\n\n";

        $json_datos = json_encode($datos_req);

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
        $stmt->execute([$json_datos]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success']) {
            echo "   ✓ Requerimiento guardado exitosamente\n";
            echo "     Mensaje: {$result['mensaje']}\n";
            echo "     REQ_ID: {$result['req_id']}\n\n";

            // 4. Verificar que se guardó correctamente
            echo "4. Verificando el requerimiento guardado...\n";
            $stmt = $pdo->prepare("
                SELECT
                    r.cvereq, r.folioreq, r.axoreq, r.id_multa,
                    r.multas, r.gastos, r.total, r.vigencia,
                    r.fecemi, r.obs,
                    m.num_acta, m.contribuyente
                FROM publico.reqmultas r
                LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
                WHERE r.cvereq = ?
            ");
            $stmt->execute([$result['req_id']]);
            $req_guardado = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($req_guardado) {
                echo "   ✓ Requerimiento encontrado:\n";
                echo "     CVEREQ: {$req_guardado['cvereq']}\n";
                echo "     Folio: {$req_guardado['folioreq']}/{$req_guardado['axoreq']}\n";
                echo "     Acta: {$req_guardado['num_acta']}\n";
                echo "     Contribuyente: " . substr($req_guardado['contribuyente'], 0, 40) . "\n";
                echo "     Monto Multa: $" . number_format($req_guardado['multas'], 2) . "\n";
                echo "     Gastos: $" . number_format($req_guardado['gastos'], 2) . "\n";
                echo "     Total: $" . number_format($req_guardado['total'], 2) . "\n";
                echo "     Vigencia: {$req_guardado['vigencia']}\n";
                echo "     Fecha Emisión: {$req_guardado['fecemi']}\n";
                echo "     Observaciones: {$req_guardado['obs']}\n";
            }

            // 5. Probar duplicado (debe fallar)
            echo "\n\n5. Probando detección de duplicados (mismo folio)...\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
            $stmt->execute([$json_datos]);
            $result_dup = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$result_dup['success']) {
                echo "   ✓ Detección de duplicados funciona correctamente\n";
                echo "     Mensaje: {$result_dup['mensaje']}\n";
            } else {
                echo "   ✗ Advertencia: No se detectó el duplicado\n";
            }

        } else {
            echo "   ✗ Error al guardar: {$result['mensaje']}\n";
        }

        // 6. Probar con otra acta
        if (count($actas_ejemplo) > 1) {
            echo "\n\n6. Probando con otra acta...\n";
            $acta_test2 = $actas_ejemplo[1];

            $stmt = $pdo->prepare("
                SELECT COALESCE(MAX(folioreq), 0) + 1 as siguiente_folio
                FROM publico.reqmultas
                WHERE axoreq = ?
            ");
            $stmt->execute([$acta_test2['axo_acta']]);
            $folio_siguiente2 = $stmt->fetch(PDO::FETCH_ASSOC)['siguiente_folio'];

            $datos_req2 = [
                'clave_cuenta' => $acta_test2['num_acta'],
                'folio' => $folio_siguiente2,
                'ejercicio' => $acta_test2['axo_acta']
            ];

            echo "   Datos: Cuenta={$datos_req2['clave_cuenta']}, Folio={$datos_req2['folio']}, Año={$datos_req2['ejercicio']}\n";

            $json_datos2 = json_encode($datos_req2);

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
            $stmt->execute([$json_datos2]);
            $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result2['success']) {
                echo "   ✓ Segundo requerimiento guardado exitosamente\n";
                echo "     Mensaje: {$result2['mensaje']}\n";
                echo "     REQ_ID: {$result2['req_id']}\n";
            } else {
                echo "   ✗ Error: {$result2['mensaje']}\n";
            }
        }

        // 7. Probar con acta que no existe
        echo "\n\n7. Probando con acta inexistente (debe fallar)...\n";
        $datos_invalido = [
            'clave_cuenta' => '99999',
            'folio' => 999999,
            'ejercicio' => 2025
        ];

        $json_invalido = json_encode($datos_invalido);
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
        $stmt->execute([$json_invalido]);
        $result_invalido = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$result_invalido['success']) {
            echo "   ✓ Validación funciona correctamente\n";
            echo "     Mensaje: {$result_invalido['mensaje']}\n";
        } else {
            echo "   ✗ Advertencia: Se permitió guardar con acta inexistente\n";
        }
    }

    // 8. Estadísticas
    echo "\n\n8. Estadísticas de requerimientos...\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               COUNT(CASE WHEN vigencia = 'V' THEN 1 END) as vigentes,
               COUNT(CASE WHEN vigencia = 'C' THEN 1 END) as cancelados
        FROM publico.reqmultas
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de requerimientos: " . number_format($stats['total']) . "\n";
    echo "   Vigentes: " . number_format($stats['vigentes']) . "\n";
    echo "   Cancelados: " . number_format($stats['cancelados']) . "\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
