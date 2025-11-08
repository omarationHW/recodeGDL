<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST REAL: SP sp_registro_solicitud\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Ver el último ID antes de insertar
    echo "Último ID antes de insertar:\n";
    $stmt = $pdo->query("SELECT MAX(id_tramite) as max_id FROM comun.tramites");
    $maxBefore = $stmt->fetch(PDO::FETCH_ASSOC)['max_id'];
    echo "  Max ID: {$maxBefore}\n\n";

    echo "Ejecutando SP de prueba...\n";
    echo "========================================\n";

    // Llamar al SP con datos únicos
    $testName = 'PRUEBA WIZARD ' . date('His');
    $stmt = $pdo->prepare("
        SELECT *
        FROM comun.sp_registro_solicitud(
            2,                               -- p_tipo_tramite
            1500,                            -- p_id_giro
            ?,                               -- p_actividad
            ?,                               -- p_propietario
            '3398765432',                    -- p_telefono
            'wizard@test.com',               -- p_email
            'REFORMA',                       -- p_calle
            'AMERICANA',                     -- p_colonia
            '44160',                         -- p_cp
            '999',                           -- p_numext
            'B',                             -- p_numint
            '',                              -- p_letraext
            '',                              -- p_letraint
            2,                               -- p_zona
            2,                               -- p_subzona
            150.75,                          -- p_sup_const
            120.00,                          -- p_sup_autorizada
            3,                               -- p_num_cajones
            8,                               -- p_num_empleados
            75000.00,                        -- p_inversion
            'TEST010101000',                 -- p_rfc
            'TEST010101HDFXXX01',            -- p_curp
            'Prueba real wizard',            -- p_especificaciones
            'claude_wizard'                  -- p_usuario
        )
    ");

    $stmt->execute([$testName, $testName]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "\nResultado del SP:\n";
    echo "========================================\n";
    echo "ID Trámite: " . ($result['id_tramite'] ?? 'NULL') . "\n";
    echo "Folio: " . ($result['folio'] ?? 'NULL') . "\n";
    echo "Fecha: " . ($result['fecha_registro'] ?? 'NULL') . "\n";
    echo "Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
    echo "Mensaje: " . ($result['message'] ?? 'NULL') . "\n\n";

    if ($result['success']) {
        // Ver el último ID después de insertar
        echo "Último ID después de insertar:\n";
        $stmt = $pdo->query("SELECT MAX(id_tramite) as max_id FROM comun.tramites");
        $maxAfter = $stmt->fetch(PDO::FETCH_ASSOC)['max_id'];
        echo "  Max ID: {$maxAfter}\n";
        echo "  Se insertó: " . ($maxAfter > $maxBefore ? 'SI' : 'NO') . "\n\n";

        // Buscar el registro específico del test
        echo "Buscando registro con propietario = '{$testName}':\n";
        echo "========================================\n";
        $stmt = $pdo->prepare("
            SELECT
                id_tramite,
                tipo_tramite,
                id_giro,
                LEFT(actividad, 40) as actividad,
                LEFT(propietario, 40) as propietario,
                telefono_prop,
                email,
                ubicacion,
                estatus,
                feccap,
                capturista
            FROM comun.tramites
            WHERE propietario LIKE ?
            ORDER BY id_tramite DESC
            LIMIT 1
        ");
        $stmt->execute(['%' . $testName . '%']);
        $tramite = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($tramite) {
            echo "  ✅ Registro encontrado:\n";
            foreach ($tramite as $key => $value) {
                echo "      {$key}: " . ($value ?? '(null)') . "\n";
            }
        } else {
            echo "  ❌ NO se encontró el registro con ese propietario\n";
        }
    }

    echo "\n========================================\n";
    echo "Test completado\n";
    echo "========================================\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
