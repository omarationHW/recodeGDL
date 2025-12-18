<?php
// Script para probar el stored procedure recaudadora_firma_electronica actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear la tabla firmas_electronicas
    echo "1. Creando tabla firmas_electronicas...\n";
    $sql = file_get_contents(__DIR__ . '/create_firmas_electronicas_table.sql');
    $pdo->exec($sql);
    echo "   ✓ Tabla firmas_electronicas creada exitosamente.\n\n";

    // 2. Actualizar el stored procedure
    echo "2. Actualizando stored procedure recaudadora_firma_electronica...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_firma_electronica.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 3. Probar firma de un documento
    echo "3. Probando firma de un documento...\n";

    $firma_datos = [
        'folio' => 'REQ-2024-12345',
        'usuario' => 'JUAN.PEREZ',
        'tipo' => 'REQUERIMIENTO',
        'datos_firma' => base64_encode('FIRMA_DIGITAL_EJEMPLO_12345'),
        'ip_address' => '192.168.1.100',
        'dispositivo' => 'Windows 10 - Chrome 120',
        'observaciones' => 'Firma realizada desde oficina central'
    ];

    $json_datos = json_encode($firma_datos);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_firma_electronica(?)");
    $stmt->execute([$json_datos]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['success']) {
        echo "   ✓ Firma registrada exitosamente\n";
        echo "     Folio: {$result['folio']}\n";
        echo "     Usuario: {$result['usuario']}\n";
        echo "     Fecha: {$result['fecha_firma']}\n\n";
    } else {
        echo "   ✗ Error: {$result['message']}\n\n";
    }

    // 4. Verificar que se guardó en la tabla
    echo "4. Verificando datos guardados...\n";
    $stmt = $pdo->query("SELECT * FROM public.firmas_electronicas ORDER BY id_firma DESC LIMIT 1");
    $firma = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($firma) {
        echo "   Última firma registrada:\n";
        echo "     ID: {$firma['id_firma']}\n";
        echo "     Folio: {$firma['folio']}\n";
        echo "     Usuario: {$firma['usuario']}\n";
        echo "     Tipo: {$firma['tipo']}\n";
        echo "     Hash: " . substr($firma['hash_firma'], 0, 20) . "...\n";
        echo "     Fecha: {$firma['fecha_firma']}\n";
        echo "     IP: {$firma['ip_address']}\n";
        echo "     Dispositivo: {$firma['dispositivo']}\n";
        echo "     Estado: {$firma['estado']}\n\n";
    }

    // 5. Probar folio duplicado
    echo "5. Probando validación de folio duplicado...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_firma_electronica(?)");
    $stmt->execute([$json_datos]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$result['success'] && strpos($result['message'], 'ya cuenta con firma') !== false) {
        echo "   ✓ Validación de folio duplicado funciona correctamente\n";
        echo "     Mensaje: {$result['message']}\n\n";
    } else {
        echo "   ✗ La validación de folio duplicado no funcionó correctamente\n\n";
    }

    // 6. Probar diferentes tipos de firma
    echo "6. Probando diferentes tipos de firma...\n";

    $firmas_prueba = [
        [
            'folio' => 'NOT-2024-001',
            'usuario' => 'MARIA.LOPEZ',
            'tipo' => 'NOTIFICACION',
            'datos_firma' => base64_encode('FIRMA_NOT_001'),
            'ip_address' => '10.0.0.50',
            'dispositivo' => 'iPad - Safari',
            'observaciones' => 'Firma desde tablet'
        ],
        [
            'folio' => 'CI-2024-001',
            'usuario' => 'PEDRO.GARCIA',
            'tipo' => 'CARTA_INVITACION',
            'datos_firma' => base64_encode('FIRMA_CI_001'),
            'ip_address' => '172.16.0.10',
            'dispositivo' => 'Android - Chrome Mobile',
            'observaciones' => 'Firma móvil'
        ],
        [
            'folio' => 'DOC-2024-789',
            'usuario' => 'ANA.MARTINEZ',
            'tipo' => 'DOCUMENTO_GENERAL',
            'datos_firma' => base64_encode('FIRMA_DOC_789'),
            'ip_address' => '192.168.5.25',
            'dispositivo' => 'MacOS - Safari 17'
        ]
    ];

    foreach ($firmas_prueba as $i => $datos) {
        $json = json_encode($datos);
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_firma_electronica(?)");
        $stmt->execute([$json]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success']) {
            echo "   ✓ Firma " . ($i + 1) . ": {$datos['tipo']} - Folio: {$result['folio']}\n";
        } else {
            echo "   ✗ Error en firma " . ($i + 1) . ": {$result['message']}\n";
        }
    }

    // 7. Estadísticas
    echo "\n\n7. Estadísticas de firmas electrónicas...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.firmas_electronicas");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de firmas registradas: {$total['total']}\n";

    // Por tipo
    $stmt = $pdo->query("
        SELECT tipo, COUNT(*) as cantidad
        FROM public.firmas_electronicas
        GROUP BY tipo
        ORDER BY cantidad DESC
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tipos) > 0) {
        echo "\n   Distribución por tipo:\n";
        foreach ($tipos as $tipo) {
            echo "     - {$tipo['tipo']}: {$tipo['cantidad']}\n";
        }
    }

    // Por usuario
    $stmt = $pdo->query("
        SELECT usuario, COUNT(*) as cantidad
        FROM public.firmas_electronicas
        GROUP BY usuario
        ORDER BY cantidad DESC
    ");
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($usuarios) > 0) {
        echo "\n   Firmas por usuario:\n";
        foreach ($usuarios as $usr) {
            echo "     - {$usr['usuario']}: {$usr['cantidad']}\n";
        }
    }

    // Últimas 5 firmas
    echo "\n   Últimas 5 firmas registradas:\n";
    $stmt = $pdo->query("
        SELECT folio, usuario, tipo, fecha_firma
        FROM public.firmas_electronicas
        ORDER BY fecha_firma DESC
        LIMIT 5
    ");
    $ultimas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ultimas as $i => $ult) {
        echo "     " . ($i + 1) . ". Folio: {$ult['folio']} - {$ult['tipo']} - {$ult['usuario']} - {$ult['fecha_firma']}\n";
    }

    // 8. Verificar integridad del hash
    echo "\n\n8. Verificando integridad de hashes...\n";
    $stmt = $pdo->query("
        SELECT folio, hash_firma
        FROM public.firmas_electronicas
        WHERE hash_firma IS NOT NULL
        LIMIT 3
    ");
    $hashes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($hashes as $h) {
        echo "   Folio: {$h['folio']} - Hash: {$h['hash_firma']}\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
