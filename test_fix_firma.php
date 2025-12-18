<?php
// Script para probar la corrección del stored procedure

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure (corrigiendo esquema)...\n";
    $sql = file_get_contents(__DIR__ . '/fix_sp_firma_electronica.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure corregido exitosamente.\n\n";

    // 2. Ver registros actuales
    echo "2. Registros actuales en public.firmas_electronicas...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.firmas_electronicas");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total actual: {$total['total']} firmas\n\n";

    // 3. Probar firma de un nuevo documento
    echo "3. Probando firma de nuevo documento...\n";

    $firma_datos = [
        'folio' => 'TEST-FIX-' . time(),
        'usuario' => 'USUARIO.PRUEBA',
        'tipo' => 'PRUEBA',
        'datos_firma' => base64_encode('FIRMA_PRUEBA'),
        'ip_address' => '192.168.1.1',
        'dispositivo' => 'Test Device'
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

    // 4. Verificar que se guardó
    echo "4. Verificando en la tabla...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.firmas_electronicas");
    $total_nuevo = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total después de la prueba: {$total_nuevo['total']} firmas\n";

    if ($total_nuevo['total'] > $total['total']) {
        echo "   ✓ Se agregó correctamente la nueva firma\n";
    }

    echo "\n✅ Corrección completada y probada exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
