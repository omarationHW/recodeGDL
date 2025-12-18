<?php
// Script para probar el stored procedure recaudadora_consmulpagos actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_consmulpagos...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_consmulpagos.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con cuenta conocida
    echo "2. Probando con cuenta '194783'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consmulpagos(?)");
    $stmt->execute(['194783']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " pagos encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 3 pagos:\n";
        foreach (array_slice($rows, 0, 3) as $i => $r) {
            echo "   ---\n";
            echo "   Pago " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_pago"] . "\n";
            echo "     Cuenta: " . $r["clave_cuenta"] . "\n";
            echo "     Folio: " . $r["folio_pago"] . "\n";
            echo "     Fecha: " . $r["fecha_pago"] . "\n";
            echo "     Monto: $" . number_format($r["monto_pago"], 2) . "\n";
            echo "     Concepto: " . $r["concepto"] . "\n";
            echo "     Tipo: " . $r["tipo_pago"] . "\n";
            echo "     Caja: " . $r["caja"] . "\n";
            echo "     Cajero: " . $r["cajero"] . "\n";
            echo "     Estado: " . ($r["estado"] == 'A' ? 'Activo' : 'Cancelado') . "\n";
            echo "     Días desde pago: " . $r["dias_desde_pago"] . "\n";
        }
    }

    // 3. Probar con cuenta '37399'
    echo "\n\n3. Probando con cuenta '37399'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consmulpagos(?)");
    $stmt->execute(['37399']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " pagos encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primer pago:\n";
        echo "     ID: {$r['id_pago']}\n";
        echo "     Folio: {$r['folio_pago']}\n";
        echo "     Fecha: {$r['fecha_pago']}\n";
        echo "     Monto: $" . number_format($r['monto_pago'], 2) . "\n";
        echo "     Tipo: {$r['tipo_pago']}\n";
    }

    // 4. Probar con cuenta inexistente
    echo "\n\n4. Probando con cuenta inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consmulpagos(?)");
    $stmt->execute(['999999999']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " pagos encontrados\n";

    // 5. Listar algunas cuentas con pagos
    echo "\n\n5. Buscando cuentas con pagos (primeras 5)...\n";
    $stmt = $pdo->query("
        SELECT cvecuenta, COUNT(*) as total_pagos, SUM(importe) as total_monto
        FROM publico.pagos
        GROUP BY cvecuenta
        HAVING COUNT(*) > 5
        ORDER BY total_pagos DESC
        LIMIT 5
    ");
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas con más pagos:\n";
    foreach ($cuentas as $cuenta) {
        echo "     - Cuenta {$cuenta['cvecuenta']}: {$cuenta['total_pagos']} pagos, Total: $" . number_format($cuenta['total_monto'], 2) . "\n";
    }

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
