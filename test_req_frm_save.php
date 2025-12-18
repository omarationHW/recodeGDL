<?php
// Script para probar el stored procedure recaudadora_req_frm_save actualizado

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

    // 2. Buscar multas de ejemplo para crear requerimientos
    echo "2. Buscando multas de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT id_multa, num_acta, axo_acta, contribuyente, multa
        FROM publico.multas
        WHERE num_acta IS NOT NULL
          AND axo_acta >= 2024
          AND cvepago IS NULL  -- Que no estén pagadas
          AND fecha_cancelacion IS NULL  -- Que no estén canceladas
        ORDER BY id_multa DESC
        LIMIT 5
    ");
    $multas_ejemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Multas encontradas:\n";
    foreach ($multas_ejemplo as $m) {
        echo "     - ID: {$m['id_multa']}, Acta: {$m['num_acta']}/{$m['axo_acta']}, Contribuyente: " . substr($m['contribuyente'], 0, 30) . ", Monto: $" . number_format($m['multa'], 2) . "\n";
    }

    if (count($multas_ejemplo) > 0) {
        $multa_test = $multas_ejemplo[0];

        // 3. Probar guardado de requerimiento
        echo "\n\n3. Probando guardado de requerimiento para multa {$multa_test['id_multa']}...\n";

        $datos_req = [
            'clave_cuenta' => $multa_test['num_acta'],
            'ejercicio' => $multa_test['axo_acta'],
            'id_multa' => $multa_test['id_multa'],
            'monto' => $multa_test['multa'],
            'gastos' => 500.00,
            'observaciones' => 'Requerimiento de prueba desde PHP'
        ];

        $json_datos = json_encode($datos_req);

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
        $stmt->execute([$json_datos]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success']) {
            echo "   ✓ Requerimiento guardado exitosamente\n";
            echo "     Mensaje: {$result['mensaje']}\n";
            echo "     ID REQ: {$result['id_req']}\n\n";

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
            $stmt->execute([$result['id_req']]);
            $req_guardado = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($req_guardado) {
                echo "   ✓ Requerimiento encontrado:\n";
                echo "     CVE REQ: {$req_guardado['cvereq']}\n";
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
            echo "\n\n5. Probando detección de duplicados...\n";
            $datos_req['folio'] = $req_guardado['folioreq'];  // Usar el mismo folio
            $json_datos_dup = json_encode($datos_req);

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
            $stmt->execute([$json_datos_dup]);
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

        // 6. Probar con otra multa (sin especificar folio)
        if (count($multas_ejemplo) > 1) {
            echo "\n\n6. Probando con otra multa (folio auto-generado)...\n";
            $multa_test2 = $multas_ejemplo[1];

            $datos_req2 = [
                'clave_cuenta' => $multa_test2['num_acta'],
                'ejercicio' => $multa_test2['axo_acta'],
                'id_multa' => $multa_test2['id_multa'],
                'monto' => $multa_test2['multa'],
                'gastos' => 750.00,
                'observaciones' => 'Segundo requerimiento de prueba'
            ];

            $json_datos2 = json_encode($datos_req2);

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_frm_save(?)");
            $stmt->execute([$json_datos2]);
            $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result2['success']) {
                echo "   ✓ Segundo requerimiento guardado exitosamente\n";
                echo "     Mensaje: {$result2['mensaje']}\n";
                echo "     ID REQ: {$result2['id_req']}\n";
            } else {
                echo "   ✗ Error: {$result2['mensaje']}\n";
            }
        }
    }

    // 7. Estadísticas
    echo "\n\n7. Estadísticas de requerimientos...\n";
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
