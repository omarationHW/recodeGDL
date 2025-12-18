<?php
// Script para probar el stored procedure recaudadora_imprime_desctos actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_imprime_desctos...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_imprime_desctos.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar ejemplos de descuentos otorgados
    echo "2. Buscando ejemplos de descuentos en aut_desctosotorgados...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT
            TRIM(d.id_multa) as id_multa,
            d.axo,
            COUNT(*) as cantidad,
            SUM(COALESCE(d.monto_aut, 0)) as total_monto
        FROM publico.aut_desctosotorgados d
        WHERE d.id_multa IS NOT NULL
        AND TRIM(d.id_multa) != ''
        GROUP BY TRIM(d.id_multa), d.axo
        HAVING COUNT(*) > 0
        ORDER BY cantidad DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Ejemplos encontrados:\n";
    foreach ($ejemplos as $ej) {
        echo "     - ID Multa: {$ej['id_multa']}, Año: {$ej['axo']}, ";
        echo "Cantidad: {$ej['cantidad']}, Total: \${$ej['total_monto']}\n";
    }

    if (count($ejemplos) > 0) {
        $ejemplo_1 = $ejemplos[0];

        // 3. Probar con un ID de multa válido
        echo "\n\n3. Probando con ID Multa '{$ejemplo_1['id_multa']}' y año {$ejemplo_1['axo']}...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
        $stmt->execute([trim($ejemplo_1['id_multa']), $ejemplo_1['axo']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "   Status: {$result['status']}\n";
            echo "   Mensaje: {$result['mensaje']}\n\n";

            if ($result['status'] === 'success') {
                echo "   === DETALLES DEL REPORTE ===\n";
                echo "   Folio: {$result['folio_reporte']}\n";
                echo "   Fecha: {$result['fecha_generacion']}\n";
                echo "   Total Descuentos: {$result['total_descuentos']}\n";
                echo "   Monto Total: \$" . number_format($result['monto_total'], 2) . "\n";
                echo "   Porcentaje Promedio: {$result['porcentaje_promedio']}%\n";
                if ($result['detalles_descuentos']) {
                    echo "   \n   Detalles:\n";
                    echo "   " . str_replace("\n", "\n   ", $result['detalles_descuentos']) . "\n";
                }
            }
        }

        // 4. Probar búsqueda por folio_descto
        echo "\n\n4. Buscando descuentos por folio...\n";
        $stmt_folio = $pdo->query("
            SELECT folio_descto, TRIM(id_multa) as id_multa, axo
            FROM publico.aut_desctosotorgados
            WHERE folio_descto IS NOT NULL
            LIMIT 3
        ");
        $folios = $stmt_folio->fetchAll(PDO::FETCH_ASSOC);

        if (count($folios) > 0) {
            $folio_test = $folios[0]['folio_descto'];
            echo "   Probando con folio: $folio_test\n";

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
            $stmt->execute([$folio_test, 0]);  // 0 = cualquier año
            $result2 = $stmt->fetch(PDO::FETCH_ASSOC);

            echo "   Status: {$result2['status']}\n";
            if ($result2['status'] === 'success') {
                echo "   Total Descuentos: {$result2['total_descuentos']}\n";
                echo "   Monto Total: \$" . number_format($result2['monto_total'], 2) . "\n";
            }
        }

        // 5. Probar con cuenta inexistente
        echo "\n\n5. Probando con cuenta inexistente...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
        $stmt->execute(['CUENTA_NO_EXISTE_999', 2025]);
        $result_error = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_error['status']}\n";
        echo "   Mensaje: {$result_error['mensaje']}\n";

        // 6. Probar validación de campo vacío
        echo "\n\n6. Probando con campo vacío (validación cuenta)...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
        $stmt->execute(['', 2025]);
        $result_vacio = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_vacio['status']}\n";
        echo "   Mensaje: {$result_vacio['mensaje']}\n";

        // 7. Probar validación de ejercicio vacío
        echo "\n\n7. Probando con ejercicio vacío (validación)...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
        $stmt->execute(['JBB3383', 0]);
        $result_ej_vacio = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_ej_vacio['status']}\n";
        if ($result_ej_vacio['status'] === 'success') {
            echo "   Total Descuentos: {$result_ej_vacio['total_descuentos']}\n";
            echo "   (Búsqueda sin filtro de ejercicio)\n";
        } else {
            echo "   Mensaje: {$result_ej_vacio['mensaje']}\n";
        }

        // 8. Probar con otros ejemplos
        echo "\n\n8. Probando con otros ID de multa...\n";
        for ($i = 1; $i < min(3, count($ejemplos)); $i++) {
            $ej = $ejemplos[$i];
            $id_test = trim($ej['id_multa']);
            $axo_test = $ej['axo'];

            echo "   ID Multa: $id_test, Año: $axo_test\n";

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
            $stmt->execute([$id_test, $axo_test]);
            $r = $stmt->fetch(PDO::FETCH_ASSOC);

            echo "     - Status: {$r['status']}\n";
            if ($r['status'] === 'success') {
                echo "     - Total Descuentos: {$r['total_descuentos']}\n";
                echo "     - Monto: \$" . number_format($r['monto_total'], 2) . "\n";
                echo "     - Porcentaje Prom: {$r['porcentaje_promedio']}%\n";
            }
            echo "\n";
        }
    } else {
        echo "\n   No hay datos suficientes en aut_desctosotorgados para probar.\n";
    }

    // 9. Ver formato JSON
    echo "\n9. Formato JSON para el frontend:\n";
    if (count($ejemplos) > 0) {
        $ejemplo_json = $ejemplos[0];
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_imprime_desctos(?, ?)");
        $stmt->execute([trim($ejemplo_json['id_multa']), $ejemplo_json['axo']]);
        $result_json = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
