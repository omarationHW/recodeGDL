<?php
// Script para probar el stored procedure recaudadora_reqtrans_create

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

    $sql = file_get_contents(__DIR__ . '/update_sp_reqtrans_create.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Ver registros actuales antes de insertar
    echo "\n\n2. Registros actuales en la tabla...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total, MAX(cvereq) as max_cvereq
        FROM public.reqdiftransmision
    ");
    $current = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total actual: " . $current['total'] . " registros\n";
    echo "   MAX cvereq: " . $current['max_cvereq'] . "\n";
    echo "   Próximo cvereq será: " . ($current['max_cvereq'] + 1) . "\n";

    // 3. Probar creación de registro simple
    echo "\n\n3. Probando creación de registro simple...\n\n";

    $registro = [
        'clave_cuenta' => '999888777',
        'folio' => 12345,
        'ejercicio' => 2025,
        'estatus' => 'Vigente'
    ];

    $json = json_encode($registro);
    echo "   JSON enviado: $json\n\n";

    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_create(?)");
    $stmt->execute([$json]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    $response = json_decode($result['recaudadora_reqtrans_create'], true);
    echo "   Respuesta: " . json_encode($response, JSON_PRETTY_PRINT) . "\n";

    if ($response['success']) {
        echo "   ✓ Registro creado exitosamente!\n";
        echo "   Nuevo cvereq: " . $response['cvereq'] . "\n";
    } else {
        echo "   ✗ Error: " . $response['message'] . "\n";
    }

    // 4. Verificar que el registro se creó
    if ($response['success']) {
        echo "\n\n4. Verificando registro creado...\n\n";

        $cvereq = $response['cvereq'];
        $stmt = $pdo->prepare("
            SELECT *
            FROM public.reqdiftransmision
            WHERE cvereq = ?
        ");
        $stmt->execute([$cvereq]);
        $created = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($created) {
            echo "   ✓ Registro encontrado:\n";
            echo "   - cvereq: " . $created['cvereq'] . "\n";
            echo "   - cvecuenta: " . $created['cvecuenta'] . "\n";
            echo "   - foliotransm: " . $created['foliotransm'] . "\n";
            echo "   - axoreq: " . $created['axoreq'] . "\n";
            echo "   - vigencia: " . $created['vigencia'] . "\n";
            echo "   - fecemi: " . $created['fecemi'] . "\n";
        }
    }

    // 5. Probar creación con importes
    echo "\n\n5. Probando creación con importes...\n\n";

    $registro2 = [
        'clave_cuenta' => '888777666',
        'folio' => 0,
        'ejercicio' => 2025,
        'estatus' => 'Vigente',
        'impuesto' => 1500.50,
        'recargos' => 150.00,
        'multa' => 300.00,
        'gastos' => 50.00
    ];

    $json2 = json_encode($registro2);
    echo "   JSON enviado: $json2\n\n";

    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_create(?)");
    $stmt->execute([$json2]);
    $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response2 = json_decode($result2['recaudadora_reqtrans_create'], true);
    echo "   Respuesta: " . json_encode($response2, JSON_PRETTY_PRINT) . "\n";

    if ($response2['success']) {
        echo "   ✓ Registro creado exitosamente!\n";
        echo "   Nuevo cvereq: " . $response2['cvereq'] . "\n";

        // Verificar importes
        $stmt = $pdo->prepare("
            SELECT impuesto, recargos, multa, gastos, total
            FROM public.reqdiftransmision
            WHERE cvereq = ?
        ");
        $stmt->execute([$response2['cvereq']]);
        $importes = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "\n   Importes guardados:\n";
        echo "   - Impuesto: $" . number_format($importes['impuesto'], 2) . "\n";
        echo "   - Recargos: $" . number_format($importes['recargos'], 2) . "\n";
        echo "   - Multa: $" . number_format($importes['multa'], 2) . "\n";
        echo "   - Gastos: $" . number_format($importes['gastos'], 2) . "\n";
        echo "   - Total: $" . number_format($importes['total'], 2) . "\n";
    }

    // 6. Probar validación de duplicado
    echo "\n\n6. Probando validación de duplicado...\n\n";

    $registro3 = [
        'clave_cuenta' => '999888777',  // Misma cuenta del paso 3
        'ejercicio' => 2025,            // Mismo año
        'estatus' => 'Vigente'
    ];

    $json3 = json_encode($registro3);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_create(?)");
    $stmt->execute([$json3]);
    $result3 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response3 = json_decode($result3['recaudadora_reqtrans_create'], true);
    echo "   Respuesta: " . json_encode($response3, JSON_PRETTY_PRINT) . "\n";

    if (!$response3['success']) {
        echo "   ✓ Validación funcionando correctamente\n";
        echo "   Mensaje esperado: " . $response3['message'] . "\n";
    } else {
        echo "   ✗ La validación de duplicado no funcionó\n";
    }

    // 7. Probar validación de campo requerido
    echo "\n\n7. Probando validación de campo requerido...\n\n";

    $registro4 = [
        'ejercicio' => 2025,
        // Falta clave_cuenta
    ];

    $json4 = json_encode($registro4);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_create(?)");
    $stmt->execute([$json4]);
    $result4 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response4 = json_decode($result4['recaudadora_reqtrans_create'], true);
    echo "   Respuesta: " . json_encode($response4, JSON_PRETTY_PRINT) . "\n";

    if (!$response4['success']) {
        echo "   ✓ Validación de campo requerido funcionando\n";
        echo "   Mensaje esperado: " . $response4['message'] . "\n";
    }

    // 8. Ver estado final
    echo "\n\n8. Estado final de la tabla...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total, MAX(cvereq) as max_cvereq
        FROM public.reqdiftransmision
    ");
    $final = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total final: " . $final['total'] . " registros\n";
    echo "   MAX cvereq final: " . $final['max_cvereq'] . "\n";
    echo "   Registros nuevos creados: " . ($final['total'] - $current['total']) . "\n";

    // 9. Listar últimos registros creados
    echo "\n\n9. Últimos registros creados...\n\n";

    $stmt = $pdo->query("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia, fecemi, total
        FROM public.reqdiftransmision
        ORDER BY cvereq DESC
        LIMIT 5
    ");

    echo "   Cvereq | Cuenta    | Folio   | Ejercicio | Vigencia | Fecha      | Total\n";
    echo "   " . str_repeat("-", 80) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %6d | %9s | %7s | %9d | %8s | %10s | $%8.2f\n",
            $row['cvereq'],
            $row['cvecuenta'],
            $row['foliotransm'] ?: '0',
            $row['axoreq'],
            $row['vigencia'],
            $row['fecemi'],
            $row['total']
        );
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
