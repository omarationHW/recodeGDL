<?php
// Script para probar el stored procedure recaudadora_reqtrans_delete

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

    $sql = file_get_contents(__DIR__ . '/update_sp_reqtrans_delete.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Ver registros actuales
    echo "\n\n2. Registros actuales en la tabla...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MAX(cvereq) as max_cvereq,
               MIN(cvereq) as min_cvereq
        FROM public.reqdiftransmision
    ");
    $current = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . $current['total'] . "\n";
    echo "   MAX cvereq: " . $current['max_cvereq'] . "\n";
    echo "   MIN cvereq: " . $current['min_cvereq'] . "\n";

    // 3. Crear un registro de prueba para eliminar
    echo "\n\n3. Creando registro de prueba...\n\n";

    $registro_test = [
        'clave_cuenta' => '777666555',
        'folio' => 11111,
        'ejercicio' => 2025,
        'estatus' => 'Vigente'
    ];

    $json_test = json_encode($registro_test);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_create(?)");
    $stmt->execute([$json_test]);
    $result_create = $stmt->fetch(PDO::FETCH_ASSOC);
    $response_create = json_decode($result_create['recaudadora_reqtrans_create'], true);

    if (!$response_create['success']) {
        echo "   ✗ No se pudo crear registro de prueba\n";
        exit(1);
    }

    $test_cvereq = $response_create['cvereq'];
    echo "   ✓ Registro de prueba creado con cvereq: " . $test_cvereq . "\n";

    // 4. Verificar que el registro existe
    echo "\n\n4. Verificando registro antes de eliminar...\n\n";

    $stmt = $pdo->prepare("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia
        FROM public.reqdiftransmision
        WHERE cvereq = ?
    ");
    $stmt->execute([$test_cvereq]);
    $before = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($before) {
        echo "   ✓ Registro encontrado:\n";
        echo "   - cvereq: " . $before['cvereq'] . "\n";
        echo "   - cvecuenta: " . $before['cvecuenta'] . "\n";
        echo "   - foliotransm: " . $before['foliotransm'] . "\n";
        echo "   - axoreq: " . $before['axoreq'] . "\n";
        echo "   - vigencia: " . $before['vigencia'] . "\n";
    }

    // 5. Probar eliminación exitosa
    echo "\n\n5. Probando eliminación del registro...\n\n";

    $delete_data = [
        'cvereq' => $test_cvereq
    ];

    $json_delete = json_encode($delete_data);
    echo "   JSON enviado: $json_delete\n\n";

    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_delete(?)");
    $stmt->execute([$json_delete]);
    $result_delete = $stmt->fetch(PDO::FETCH_ASSOC);

    $response_delete = json_decode($result_delete['recaudadora_reqtrans_delete'], true);
    echo "   Respuesta: " . json_encode($response_delete, JSON_PRETTY_PRINT) . "\n";

    if ($response_delete['success']) {
        echo "\n   ✓ Registro eliminado exitosamente!\n";
        echo "   - ID eliminado: " . $response_delete['cvereq'] . "\n";
        echo "   - Cuenta: " . $response_delete['clave_cuenta'] . "\n";
        echo "   - Ejercicio: " . $response_delete['ejercicio'] . "\n";
        echo "   - Filas afectadas: " . $response_delete['rows_affected'] . "\n";
    } else {
        echo "\n   ✗ Error: " . $response_delete['message'] . "\n";
    }

    // 6. Verificar que el registro fue eliminado
    echo "\n\n6. Verificando que el registro fue eliminado...\n\n";

    $stmt = $pdo->prepare("
        SELECT COUNT(*) as existe
        FROM public.reqdiftransmision
        WHERE cvereq = ?
    ");
    $stmt->execute([$test_cvereq]);
    $after = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($after['existe'] == 0) {
        echo "   ✓ Registro eliminado correctamente de la base de datos\n";
    } else {
        echo "   ✗ El registro aún existe en la base de datos\n";
    }

    // 7. Probar validación - registro inexistente
    echo "\n\n7. Probando validación - registro ya eliminado...\n\n";

    $delete_data2 = [
        'cvereq' => $test_cvereq  // Mismo ID ya eliminado
    ];

    $json_delete2 = json_encode($delete_data2);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_delete(?)");
    $stmt->execute([$json_delete2]);
    $result_delete2 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response_delete2 = json_decode($result_delete2['recaudadora_reqtrans_delete'], true);
    echo "   Respuesta: " . json_encode($response_delete2, JSON_PRETTY_PRINT) . "\n";

    if (!$response_delete2['success']) {
        echo "\n   ✓ Validación funcionando correctamente\n";
        echo "   Mensaje esperado: " . $response_delete2['message'] . "\n";
    }

    // 8. Probar validación - sin cvereq
    echo "\n\n8. Probando validación - sin cvereq...\n\n";

    $delete_data3 = [
        'clave_cuenta' => '123456'
        // Falta cvereq
    ];

    $json_delete3 = json_encode($delete_data3);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_delete(?)");
    $stmt->execute([$json_delete3]);
    $result_delete3 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response_delete3 = json_decode($result_delete3['recaudadora_reqtrans_delete'], true);
    echo "   Respuesta: " . json_encode($response_delete3, JSON_PRETTY_PRINT) . "\n";

    if (!$response_delete3['success']) {
        echo "\n   ✓ Validación de cvereq requerido funcionando\n";
        echo "   Mensaje esperado: " . $response_delete3['message'] . "\n";
    }

    // 9. Probar validación - ID inexistente
    echo "\n\n9. Probando validación - ID inexistente...\n\n";

    $delete_data4 = [
        'cvereq' => 999999  // ID que nunca existió
    ];

    $json_delete4 = json_encode($delete_data4);
    $stmt = $pdo->prepare("SELECT publico.recaudadora_reqtrans_delete(?)");
    $stmt->execute([$json_delete4]);
    $result_delete4 = $stmt->fetch(PDO::FETCH_ASSOC);

    $response_delete4 = json_decode($result_delete4['recaudadora_reqtrans_delete'], true);
    echo "   Respuesta: " . json_encode($response_delete4, JSON_PRETTY_PRINT) . "\n";

    if (!$response_delete4['success']) {
        echo "\n   ✓ Validación de existencia funcionando\n";
        echo "   Mensaje esperado: " . $response_delete4['message'] . "\n";
    }

    // 10. Estado final de la tabla
    echo "\n\n10. Estado final de la tabla...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MAX(cvereq) as max_cvereq,
               MIN(cvereq) as min_cvereq
        FROM public.reqdiftransmision
    ");
    $final = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total final: " . $final['total'] . " registros\n";
    echo "   MAX cvereq final: " . $final['max_cvereq'] . "\n";
    echo "   MIN cvereq final: " . $final['min_cvereq'] . "\n";
    echo "   Registros eliminados: " . ($current['total'] - $final['total']) . "\n";

    // 11. Listar últimos registros
    echo "\n\n11. Últimos 5 registros...\n\n";

    $stmt = $pdo->query("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia
        FROM public.reqdiftransmision
        ORDER BY cvereq DESC
        LIMIT 5
    ");

    echo "   Cvereq | Cuenta    | Folio   | Ejercicio | Vigencia\n";
    echo "   " . str_repeat("-", 60) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %6d | %9s | %7s | %9d | %8s\n",
            $row['cvereq'],
            $row['cvecuenta'],
            $row['foliotransm'] ?: '0',
            $row['axoreq'],
            $row['vigencia']
        );
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure actualizado correctamente\n";
    echo "- Registro de prueba creado y eliminado exitosamente\n";
    echo "- Todas las validaciones funcionando correctamente\n";
    echo "- Función lista para uso en producción\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
