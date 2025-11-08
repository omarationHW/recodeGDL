<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST: SP sp_registro_solicitud\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    echo "Ejecutando SP de prueba...\n";
    echo "========================================\n";

    // Llamar al SP con datos de prueba
    $stmt = $pdo->prepare("
        SELECT *
        FROM comun.sp_registro_solicitud(
            1,                               -- p_tipo_tramite
            1091,                            -- p_id_giro
            'PRUEBA WIZARD VUE',             -- p_actividad
            'JUAN PEREZ TEST',               -- p_propietario
            '3312345678',                    -- p_telefono
            'test@ejemplo.com',              -- p_email
            'AV REVOLUCION',                 -- p_calle
            'CENTRO',                        -- p_colonia
            '44100',                         -- p_cp
            '123',                           -- p_numext
            'A',                             -- p_numint
            '',                              -- p_letraext
            '',                              -- p_letraint
            1,                               -- p_zona
            1,                               -- p_subzona
            100.50,                          -- p_sup_const
            80.00,                           -- p_sup_autorizada
            2,                               -- p_num_cajones
            5,                               -- p_num_empleados
            50000.00,                        -- p_inversion
            'XAXX010101000',                 -- p_rfc
            'XAXX010101HDFXXX00',            -- p_curp
            'Prueba desde wizard Vue.js',   -- p_especificaciones
            'claude'                         -- p_usuario
        )
    ");

    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "\nResultado del SP:\n";
    echo "========================================\n";
    echo "ID Trámite: " . ($result['id_tramite'] ?? 'NULL') . "\n";
    echo "Folio: " . ($result['folio'] ?? 'NULL') . "\n";
    echo "Fecha: " . ($result['fecha_registro'] ?? 'NULL') . "\n";
    echo "Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
    echo "Mensaje: " . ($result['message'] ?? 'NULL') . "\n";

    if ($result['success']) {
        echo "\n✅ SP ejecutado exitosamente\n";

        // Verificar que se guardó
        echo "\nVerificando registro en la BD:\n";
        echo "========================================\n";
        $stmt = $pdo->prepare("
            SELECT
                id_tramite,
                tipo_tramite,
                id_giro,
                actividad,
                propietario,
                telefono_prop,
                email,
                estatus,
                feccap,
                capturista
            FROM comun.tramites
            WHERE id_tramite = ?
        ");
        $stmt->execute([$result['id_tramite']]);
        $tramite = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($tramite) {
            echo "  ✅ Trámite encontrado:\n";
            foreach ($tramite as $key => $value) {
                echo "      {$key}: {$value}\n";
            }
        } else {
            echo "  ❌ Trámite NO encontrado en la BD\n";
        }
    } else {
        echo "\n❌ Error al ejecutar SP:\n";
        echo "    " . $result['message'] . "\n";
    }

    echo "\n========================================\n";
    echo "Test completado\n";
    echo "========================================\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
