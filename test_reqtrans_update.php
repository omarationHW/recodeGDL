<?php
// Script para probar el stored procedure recaudadora_reqtrans_update

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar stored procedure
    echo "1. Actualizando stored procedure...\n\n";

    $sql = file_get_contents(__DIR__ . '/update_sp_reqtrans_update.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Obtener un registro existente para actualizar
    echo "\n\n2. Obteniendo registro para actualizar...\n\n";

    $stmt = $pdo->query("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia, impuesto, recargos, multa, gastos, total
        FROM public.reqdiftransmision
        ORDER BY cvereq DESC
        LIMIT 1
    ");

    $registro = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$registro) {
        echo "   ✗ No hay registros en la tabla para actualizar\n";
        exit(0);
    }

    echo "   Registro seleccionado:\n";
    echo "   - cvereq: " . $registro['cvereq'] . "\n";
    echo "   - cvecuenta: " . $registro['cvecuenta'] . "\n";
    echo "   - foliotransm: " . $registro['foliotransm'] . "\n";
    echo "   - axoreq: " . $registro['axoreq'] . "\n";
    echo "   - vigencia: " . $registro['vigencia'] . "\n";
    echo "   - impuesto: $" . number_format($registro['impuesto'], 2) . "\n";
    echo "   - total: $" . number_format($registro['total'], 2) . "\n";

    // 3. Probar actualización simple (solo campos básicos)
    echo "\n\n3. Probando actualización simple...\n\n";

    $update1 = [
        'cvereq' => $registro['cvereq'],
        'clave_cuenta' => $registro['cvecuenta'],
        'folio' => 99999,  // Cambiar folio
        'ejercicio' => $registro['axoreq'],
        'estatus' => 'Vigente'
    ];

    $json1 = json_encode($update1);
    echo "   JSON enviado: $json1\n\n";

    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_update(?)");
    $stmt->execute([$json1]);
    $result1 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response1 = json_decode($result1['recaudadora_reqtrans_update'], true);
    echo "   Respuesta: " . json_encode($response1, JSON_PRETTY_PRINT) . "\n";

    if ($response1['success']) {
        echo "   ✓ Registro actualizado exitosamente!\n";
        echo "   Filas afectadas: " . $response1['rows_affected'] . "\n";

        // Verificar cambio
        $stmt = $pdo->prepare("SELECT foliotransm FROM public.reqdiftransmision WHERE cvereq = ?");
        $stmt->execute([$registro['cvereq']]);
        $updated = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Nuevo folio: " . $updated['foliotransm'] . "\n";
    } else {
        echo "   ✗ Error: " . $response1['message'] . "\n";
    }

    // 4. Probar actualización con importes
    echo "\n\n4. Probando actualización con importes...\n\n";

    $update2 = [
        'cvereq' => $registro['cvereq'],
        'clave_cuenta' => $registro['cvecuenta'],
        'folio' => 99999,
        'ejercicio' => $registro['axoreq'],
        'estatus' => 'Vigente',
        'impuesto' => 2500.75,
        'recargos' => 250.00,
        'multa' => 500.00,
        'gastos' => 100.00
    ];

    $json2 = json_encode($update2);
    echo "   JSON enviado: $json2\n\n";

    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_update(?)");
    $stmt->execute([$json2]);
    $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response2 = json_decode($result2['recaudadora_reqtrans_update'], true);
    echo "   Respuesta: " . json_encode($response2, JSON_PRETTY_PRINT) . "\n";

    if ($response2['success']) {
        echo "   ✓ Registro actualizado exitosamente!\n";

        // Verificar importes
        $stmt = $pdo->prepare("
            SELECT impuesto, recargos, multa, gastos, total
            FROM public.reqdiftransmision
            WHERE cvereq = ?
        ");
        $stmt->execute([$registro['cvereq']]);
        $importes = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "\n   Importes actualizados:\n";
        echo "   - Impuesto: $" . number_format($importes['impuesto'], 2) . "\n";
        echo "   - Recargos: $" . number_format($importes['recargos'], 2) . "\n";
        echo "   - Multa: $" . number_format($importes['multa'], 2) . "\n";
        echo "   - Gastos: $" . number_format($importes['gastos'], 2) . "\n";
        echo "   - Total: $" . number_format($importes['total'], 2) . " (calculado automáticamente)\n";
    }

    // 5. Probar actualización de estatus
    echo "\n\n5. Probando actualización de estatus...\n\n";

    $update3 = [
        'cvereq' => $registro['cvereq'],
        'clave_cuenta' => $registro['cvecuenta'],
        'folio' => 99999,
        'ejercicio' => $registro['axoreq'],
        'estatus' => 'Cancelado'  // Cambiar a Cancelado
    ];

    $json3 = json_encode($update3);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_update(?)");
    $stmt->execute([$json3]);
    $result3 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response3 = json_decode($result3['recaudadora_reqtrans_update'], true);

    if ($response3['success']) {
        echo "   ✓ Estatus actualizado\n";

        $stmt = $pdo->prepare("SELECT vigencia FROM public.reqdiftransmision WHERE cvereq = ?");
        $stmt->execute([$registro['cvereq']]);
        $vigencia = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Nueva vigencia: " . $vigencia['vigencia'] . " (C = Cancelado)\n";
    }

    // 6. Restaurar estatus a Vigente
    echo "\n\n6. Restaurando estatus a Vigente...\n\n";

    $update4 = [
        'cvereq' => $registro['cvereq'],
        'clave_cuenta' => $registro['cvecuenta'],
        'folio' => 99999,
        'ejercicio' => $registro['axoreq'],
        'estatus' => 'Vigente'
    ];

    $json4 = json_encode($update4);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_update(?)");
    $stmt->execute([$json4]);
    $result4 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response4 = json_decode($result4['recaudadora_reqtrans_update'], true);

    if ($response4['success']) {
        echo "   ✓ Estatus restaurado a Vigente\n";
    }

    // 7. Probar validación - registro inexistente
    echo "\n\n7. Probando validación - registro inexistente...\n\n";

    $update5 = [
        'cvereq' => 999999,  // ID que no existe
        'clave_cuenta' => '123456',
        'folio' => 0,
        'ejercicio' => 2025,
        'estatus' => 'Vigente'
    ];

    $json5 = json_encode($update5);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_update(?)");
    $stmt->execute([$json5]);
    $result5 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response5 = json_decode($result5['recaudadora_reqtrans_update'], true);
    echo "   Respuesta: " . json_encode($response5, JSON_PRETTY_PRINT) . "\n";

    if (!$response5['success']) {
        echo "   ✓ Validación funcionando correctamente\n";
        echo "   Mensaje esperado: " . $response5['message'] . "\n";
    }

    // 8. Probar validación - sin cvereq
    echo "\n\n8. Probando validación - sin cvereq...\n\n";

    $update6 = [
        'clave_cuenta' => '123456',
        'folio' => 0,
        'ejercicio' => 2025
        // Falta cvereq
    ];

    $json6 = json_encode($update6);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_update(?)");
    $stmt->execute([$json6]);
    $result6 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response6 = json_decode($result6['recaudadora_reqtrans_update'], true);
    echo "   Respuesta: " . json_encode($response6, JSON_PRETTY_PRINT) . "\n";

    if (!$response6['success']) {
        echo "   ✓ Validación de cvereq requerido funcionando\n";
        echo "   Mensaje esperado: " . $response6['message'] . "\n";
    }

    // 9. Verificar estado final del registro
    echo "\n\n9. Estado final del registro actualizado...\n\n";

    $stmt = $pdo->prepare("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia,
               impuesto, recargos, multa, gastos, total
        FROM public.reqdiftransmision
        WHERE cvereq = ?
    ");
    $stmt->execute([$registro['cvereq']]);
    $final = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Registro final:\n";
    echo "   - cvereq: " . $final['cvereq'] . "\n";
    echo "   - cvecuenta: " . $final['cvecuenta'] . "\n";
    echo "   - foliotransm: " . $final['foliotransm'] . "\n";
    echo "   - axoreq: " . $final['axoreq'] . "\n";
    echo "   - vigencia: " . $final['vigencia'] . "\n";
    echo "   - impuesto: $" . number_format($final['impuesto'], 2) . "\n";
    echo "   - recargos: $" . number_format($final['recargos'], 2) . "\n";
    echo "   - multa: $" . number_format($final['multa'], 2) . "\n";
    echo "   - gastos: $" . number_format($final['gastos'], 2) . "\n";
    echo "   - total: $" . number_format($final['total'], 2) . "\n";

    echo "\n\n✅ Todas las pruebas completadas!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
