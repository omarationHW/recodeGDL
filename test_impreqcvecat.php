<?php
// Script para probar el stored procedure recaudadora_impreqcvecat actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_impreqcvecat...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_impreqcvecat.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar claves catastrales de ejemplo
    echo "2. Buscando claves catastrales de ejemplo en req_400...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT TRIM(ctarfc) as clave, folreq, ejereq, impcuo
        FROM req_400
        WHERE ctarfc IS NOT NULL
          AND TRIM(ctarfc) != ''
        LIMIT 5
    ");
    $claves_ejemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Claves encontradas:\n";
    foreach ($claves_ejemplo as $c) {
        echo "     - Clave: {$c['clave']}, Folio: {$c['folreq']}, Ejercicio: {$c['ejereq']}\n";
    }

    if (count($claves_ejemplo) > 0) {
        $clave_test = $claves_ejemplo[0]['clave'];

        // 3. Probar con clave catastral válida
        echo "\n\n3. Probando con clave catastral '{$clave_test}'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impreqcvecat(?)");
        $stmt->execute([$clave_test]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "   Status: {$result['status']}\n";
            echo "   Mensaje: {$result['mensaje']}\n\n";

            if ($result['status'] === 'success') {
                echo "   === DETALLES DEL REQUERIMIENTO ===\n";
                echo "   Folio: {$result['folio_requerimiento']}\n";
                echo "   Fecha Generación: {$result['fecha_generacion']}\n";
                echo "   Propietario: {$result['propietario']}\n";
                echo "   Dirección: {$result['direccion']}\n";
                echo "   Monto Adeudo: $" . number_format($result['monto_adeudo'], 2) . "\n";
                echo "   Clave Catastral: {$result['clave_catastral']}\n";
                echo "   Ejercicio: {$result['ejercicio']}\n";
                echo "   Periodo: {$result['periodo']}\n";
                echo "   Tipo: {$result['tipo_requerimiento']}\n";
                echo "   Observaciones: {$result['observaciones']}\n";
            }
        }

        // 4. Probar con clave catastral inexistente
        echo "\n\n4. Probando con clave catastral inexistente...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impreqcvecat(?)");
        $stmt->execute(['999999999999999']);
        $result_error = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_error['status']}\n";
        echo "   Mensaje: {$result_error['mensaje']}\n";

        // 5. Probar con clave vacía
        echo "\n\n5. Probando con clave vacía (validación)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impreqcvecat(?)");
        $stmt->execute(['']);
        $result_vacio = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Status: {$result_vacio['status']}\n";
        echo "   Mensaje: {$result_vacio['mensaje']}\n";

        // 6. Probar con más claves
        echo "\n\n6. Probando con otras claves catastrales...\n";
        for ($i = 1; $i < min(3, count($claves_ejemplo)); $i++) {
            $clave = $claves_ejemplo[$i]['clave'];
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impreqcvecat(?)");
            $stmt->execute([$clave]);
            $r = $stmt->fetch(PDO::FETCH_ASSOC);

            echo "   Clave: $clave\n";
            echo "     - Status: {$r['status']}\n";
            echo "     - Folio: {$r['folio_requerimiento']}\n";
            echo "     - Monto: $" . number_format($r['monto_adeudo'], 2) . "\n";
            echo "\n";
        }
    }

    // 7. Ver formato JSON (como lo recibirá el frontend)
    echo "\n7. Formato JSON para el frontend:\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_impreqcvecat(?)");
    $stmt->execute([$claves_ejemplo[0]['clave']]);
    $result_json = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
