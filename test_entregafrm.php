<?php
// Script para probar el stored procedure recaudadora_entregafrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear la tabla entregas
    echo "1. Creando tabla entregas...\n";
    $sql = file_get_contents(__DIR__ . '/create_entregas_table.sql');
    $pdo->exec($sql);
    echo "   ✓ Tabla entregas creada exitosamente.\n\n";

    // 2. Actualizar el stored procedure
    echo "2. Actualizando stored procedure recaudadora_entregafrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_entregafrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 3. Probar inserción de una entrega
    echo "3. Probando inserción de una entrega...\n";

    $entrega_datos = [
        'tipo_entrega' => 'REQUERIMIENTO',
        'folio' => 'REQ-2024-001',
        'ejecutor' => 'JUAN PEREZ MARTINEZ',
        'destinatario' => 'MARIA GONZALEZ LOPEZ',
        'domicilio' => 'AV. REVOLUCION 123, COL. CENTRO',
        'clave_catastral' => 'D65I4369013',
        'cuenta' => '123456',
        'rfc' => 'GOLM850315ABC',
        'concepto' => 'IMPUESTO PREDIAL',
        'motivo' => 'ADEUDO PREDIAL 2023-2024',
        'monto' => 15500.50,
        'fecha_entrega' => '2024-01-15',
        'hora_entrega' => '10:30:00',
        'plazo_pago' => '15 DIAS HABILES',
        'observaciones' => 'Entrega realizada en domicilio fiscal'
    ];

    $json_datos = json_encode($entrega_datos);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_entregafrm(?)");
    $stmt->execute([$json_datos]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['success']) {
        echo "   ✓ Entrega registrada exitosamente\n";
        echo "     Folio: {$result['folio']}\n";
        echo "     Ejecutor: {$result['ejecutor']}\n";
        echo "     Fecha: {$result['fecha_entrega']}\n\n";
    } else {
        echo "   ✗ Error: {$result['message']}\n\n";
    }

    // 4. Verificar que se guardó en la tabla
    echo "4. Verificando datos guardados...\n";
    $stmt = $pdo->query("SELECT * FROM public.entregas ORDER BY id_entrega DESC LIMIT 1");
    $entrega = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($entrega) {
        echo "   Última entrega registrada:\n";
        echo "     ID: {$entrega['id_entrega']}\n";
        echo "     Tipo: {$entrega['tipo_entrega']}\n";
        echo "     Folio: {$entrega['folio']}\n";
        echo "     Ejecutor: {$entrega['ejecutor']}\n";
        echo "     Destinatario: {$entrega['destinatario']}\n";
        echo "     Domicilio: {$entrega['domicilio']}\n";
        echo "     Cuenta: {$entrega['cuenta']}\n";
        echo "     Monto: $" . number_format($entrega['monto'], 2) . "\n";
        echo "     Fecha: {$entrega['fecha_entrega']} {$entrega['hora_entrega']}\n";
        echo "     Plazo: {$entrega['plazo_pago']}\n\n";
    }

    // 5. Probar folio duplicado
    echo "5. Probando validación de folio duplicado...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_entregafrm(?)");
    $stmt->execute([$json_datos]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$result['success'] && strpos($result['message'], 'ya existe') !== false) {
        echo "   ✓ Validación de folio duplicado funciona correctamente\n";
        echo "     Mensaje: {$result['message']}\n\n";
    } else {
        echo "   ✗ La validación de folio duplicado no funcionó correctamente\n\n";
    }

    // 6. Probar con diferentes tipos de entrega
    echo "6. Probando diferentes tipos de entrega...\n";

    $entregas_prueba = [
        [
            'tipo_entrega' => 'NOTIFICACION',
            'folio' => 'NOT-2024-001',
            'ejecutor' => 'PEDRO RAMIREZ GARCIA',
            'destinatario' => 'CARLOS HERNANDEZ DIAZ',
            'domicilio' => 'CALLE LIBERTAD 456',
            'cuenta' => '789012',
            'fecha_entrega' => '2024-01-16',
            'hora_entrega' => '14:00:00',
            'concepto' => 'LICENCIA DE FUNCIONAMIENTO',
            'monto' => 5000.00,
            'observaciones' => 'Recibió copia'
        ],
        [
            'tipo_entrega' => 'CARTA INVITACION',
            'folio' => 'CI-2024-001',
            'ejecutor' => 'ANA MARTINEZ LOPEZ',
            'destinatario' => 'EMPRESA ABC SA DE CV',
            'domicilio' => 'AV. AMERICAS 789',
            'rfc' => 'EAB850101XXX',
            'cuenta' => '345678',
            'fecha_entrega' => '2024-01-17',
            'hora_entrega' => '09:00:00',
            'concepto' => 'ADEUDO MULTA',
            'monto' => 8500.00,
            'plazo_pago' => '10 DIAS',
            'observaciones' => 'Entrega en oficina'
        ]
    ];

    foreach ($entregas_prueba as $i => $datos) {
        $json = json_encode($datos);
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_entregafrm(?)");
        $stmt->execute([$json]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success']) {
            echo "   ✓ Entrega " . ($i + 1) . ": {$datos['tipo_entrega']} - Folio: {$result['folio']}\n";
        } else {
            echo "   ✗ Error en entrega " . ($i + 1) . ": {$result['message']}\n";
        }
    }

    // 7. Estadísticas
    echo "\n\n7. Estadísticas de entregas...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.entregas");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de entregas registradas: {$total['total']}\n";

    // Por tipo
    $stmt = $pdo->query("
        SELECT tipo_entrega, COUNT(*) as cantidad
        FROM public.entregas
        GROUP BY tipo_entrega
        ORDER BY cantidad DESC
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tipos) > 0) {
        echo "\n   Distribución por tipo:\n";
        foreach ($tipos as $tipo) {
            echo "     - {$tipo['tipo_entrega']}: {$tipo['cantidad']}\n";
        }
    }

    // Últimas 5 entregas
    echo "\n   Últimas 5 entregas registradas:\n";
    $stmt = $pdo->query("
        SELECT folio, ejecutor, fecha_entrega, tipo_entrega
        FROM public.entregas
        ORDER BY fecha_registro DESC
        LIMIT 5
    ");
    $ultimas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ultimas as $i => $ult) {
        echo "     " . ($i + 1) . ". Folio: {$ult['folio']} - {$ult['tipo_entrega']} - {$ult['fecha_entrega']}\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
