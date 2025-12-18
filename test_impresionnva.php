<?php
// Script para probar el stored procedure recaudadora_impresionnva actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_impresionnva...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_impresionnva.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar cuentas de ejemplo
    echo "2. Buscando cuentas de ejemplo en req_400...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT TRIM(ctarfc) as cuenta, TRIM(folreq) as folio, tpr, impcuo
        FROM req_400
        WHERE ctarfc IS NOT NULL AND TRIM(ctarfc) != ''
        LIMIT 5
    ");
    $cuentas_ejemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas encontradas:\n";
    foreach ($cuentas_ejemplo as $c) {
        echo "     - Cuenta: {$c['cuenta']}, Folio: {$c['folio']}, Tipo: {$c['tpr']}\n";
    }

    if (count($cuentas_ejemplo) > 0) {
        $cuenta_test = $cuentas_ejemplo[0]['cuenta'];

        // 3. Probar con cuenta válida
        echo "\n\n3. Probando con cuenta '{$cuenta_test}'...\n";
        $datos_json = json_encode(['clave_cuenta' => $cuenta_test]);

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impresionnva(?)");
        $stmt->execute([$datos_json]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "   Status: {$result['status']}\n";
            echo "   Mensaje: {$result['mensaje']}\n\n";

            if ($result['status'] === 'success') {
                echo "   === DETALLES DE LA IMPRESIÓN ===\n";
                echo "   Folio: {$result['folio_impresion']}\n";
                echo "   Fecha: {$result['fecha_generacion']}\n";
                echo "   Tipo Documento: {$result['tipo_documento']}\n";
                echo "   Páginas: {$result['numero_paginas']}\n";
                echo "   Clave Cuenta: {$result['clave_cuenta']}\n";
                echo "   Contribuyente: {$result['contribuyente']}\n";
                echo "   Monto: $" . number_format($result['monto_total'], 2) . "\n";
                echo "   Periodo: {$result['periodo']}\n";
                echo "   Estado: {$result['estado']}\n";
                echo "   Formato: {$result['formato']}\n";
                echo "   Observaciones: {$result['observaciones']}\n";
            }
        }

        // 4. Probar con cuenta por folio
        echo "\n\n4. Probando búsqueda por folio...\n";
        $folio_test = $cuentas_ejemplo[1]['folio'] ?? $cuentas_ejemplo[0]['folio'];
        $datos_json2 = json_encode(['clave_cuenta' => $folio_test]);

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impresionnva(?)");
        $stmt->execute([$datos_json2]);
        $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Folio buscado: $folio_test\n";
        echo "   Status: {$result2['status']}\n";
        if ($result2['status'] === 'success') {
            echo "   Folio Impresión: {$result2['folio_impresion']}\n";
            echo "   Tipo: {$result2['tipo_documento']}\n";
            echo "   Monto: $" . number_format($result2['monto_total'], 2) . "\n";
        }

        // 5. Probar con cuenta inexistente
        echo "\n\n5. Probando con cuenta inexistente...\n";
        $datos_invalido = json_encode(['clave_cuenta' => '999999999999']);

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impresionnva(?)");
        $stmt->execute([$datos_invalido]);
        $result_error = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_error['status']}\n";
        echo "   Mensaje: {$result_error['mensaje']}\n";

        // 6. Probar validación de campo vacío
        echo "\n\n6. Probando con campo vacío (validación)...\n";
        $datos_vacio = json_encode(['clave_cuenta' => '']);

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impresionnva(?)");
        $stmt->execute([$datos_vacio]);
        $result_vacio = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_vacio['status']}\n";
        echo "   Mensaje: {$result_vacio['mensaje']}\n";

        // 7. Probar con más cuentas
        echo "\n\n7. Probando con otras cuentas...\n";
        for ($i = 2; $i < min(4, count($cuentas_ejemplo)); $i++) {
            $cuenta = $cuentas_ejemplo[$i]['cuenta'];
            $datos = json_encode(['clave_cuenta' => $cuenta]);

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impresionnva(?)");
            $stmt->execute([$datos]);
            $r = $stmt->fetch(PDO::FETCH_ASSOC);

            echo "   Cuenta: $cuenta\n";
            echo "     - Status: {$r['status']}\n";
            if ($r['status'] === 'success') {
                echo "     - Folio: {$r['folio_impresion']}\n";
                echo "     - Tipo: {$r['tipo_documento']}\n";
                echo "     - Páginas: {$r['numero_paginas']}\n";
            }
            echo "\n";
        }
    }

    // 8. Ver formato JSON
    echo "\n8. Formato JSON para el frontend:\n";
    $cuenta_json = $cuentas_ejemplo[0]['cuenta'];
    $datos_json_final = json_encode(['clave_cuenta' => $cuenta_json]);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impresionnva(?)");
    $stmt->execute([$datos_json_final]);
    $result_json = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
