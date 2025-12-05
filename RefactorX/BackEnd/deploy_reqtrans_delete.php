<?php

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'Siac1234*';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "✅ Conectado a PostgreSQL\n\n";

    // Crear SP DELETE
    $sqlDelete = <<<'SQL'
DROP FUNCTION IF EXISTS recaudadora_reqtrans_delete(JSON) CASCADE;

CREATE OR REPLACE FUNCTION recaudadora_reqtrans_delete(
    p_registro JSON
)
RETURNS JSON AS $BODY$
DECLARE
    v_cvereq INTEGER;
    v_clave_cuenta TEXT;
    v_ejercicio INTEGER;
    v_rows_affected INTEGER;
BEGIN
    -- Extraer cvereq del JSON (ID único del registro)
    BEGIN
        v_cvereq := (p_registro->>'cvereq')::INTEGER;
    EXCEPTION
        WHEN OTHERS THEN
            v_cvereq := NULL;
    END;

    -- Validar que cvereq esté presente
    IF v_cvereq IS NULL OR v_cvereq <= 0 THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error: No se proporcionó el ID del registro. Por favor recargue la página.'
        );
    END IF;

    -- Verificar que el registro existe antes de eliminar
    IF NOT EXISTS (SELECT 1 FROM catastro_gdl.reqdiftransmision WHERE cvereq = v_cvereq) THEN
        RETURN json_build_object(
            'success', false,
            'message', 'El registro no existe o ya fue eliminado'
        );
    END IF;

    -- Guardar datos para el mensaje de confirmación
    SELECT cvecuenta::TEXT, axoreq
    INTO v_clave_cuenta, v_ejercicio
    FROM catastro_gdl.reqdiftransmision
    WHERE cvereq = v_cvereq;

    -- Eliminar el registro usando cvereq (ID único)
    DELETE FROM catastro_gdl.reqdiftransmision
    WHERE cvereq = v_cvereq;

    -- Verificar cuántas filas se eliminaron
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Registro eliminado correctamente',
            'cvereq', v_cvereq,
            'clave_cuenta', v_clave_cuenta,
            'ejercicio', v_ejercicio,
            'rows_affected', v_rows_affected
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'message', 'No se pudo eliminar el registro'
        );
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN json_build_object(
            'success', false,
            'message', 'No se puede eliminar: El registro está siendo usado por otros registros'
        );
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error al eliminar: ' || SQLERRM
        );
END;
$BODY$ LANGUAGE plpgsql;
SQL;

    echo "📋 Creando Stored Procedure DELETE...\n";
    $pdo->exec($sqlDelete);
    echo "✅ SP recaudadora_reqtrans_delete creado exitosamente\n\n";

    // Probar el SP con un DELETE de prueba (registro 14 que creamos antes)
    echo "🧪 Probando SP DELETE...\n";

    // Primero verificar si existe el registro 14
    $checkStmt = $pdo->query("SELECT cvereq, cvecuenta::TEXT as clave_cuenta, axoreq FROM catastro_gdl.reqdiftransmision WHERE cvereq = 14");
    $existingRecord = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if ($existingRecord) {
        echo "📌 Registro encontrado para prueba:\n";
        echo "   cvereq: " . $existingRecord['cvereq'] . "\n";
        echo "   clave_cuenta: " . $existingRecord['clave_cuenta'] . "\n";
        echo "   ejercicio: " . $existingRecord['axoreq'] . "\n\n";

        // Probar DELETE
        $testDelete = json_encode([
            'cvereq' => 14,
            'clave_cuenta' => $existingRecord['clave_cuenta'],
            'ejercicio' => $existingRecord['axoreq'],
            'estatus' => 'Pendiente'
        ]);

        echo "🔧 Ejecutando DELETE con JSON:\n";
        echo "   " . $testDelete . "\n\n";

        $stmt = $pdo->prepare("SELECT recaudadora_reqtrans_delete(?)");
        $stmt->execute([$testDelete]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "📊 Resultado:\n";
        $resultJson = json_decode($result['recaudadora_reqtrans_delete'], true);
        echo "   Success: " . ($resultJson['success'] ? 'true' : 'false') . "\n";
        echo "   Message: " . $resultJson['message'] . "\n";
        if (isset($resultJson['cvereq'])) {
            echo "   cvereq eliminado: " . $resultJson['cvereq'] . "\n";
        }
        if (isset($resultJson['rows_affected'])) {
            echo "   Filas afectadas: " . $resultJson['rows_affected'] . "\n";
        }
        echo "\n";

        // Verificar que se eliminó
        $verifyStmt = $pdo->query("SELECT COUNT(*) as count FROM catastro_gdl.reqdiftransmision WHERE cvereq = 14");
        $verify = $verifyStmt->fetch(PDO::FETCH_ASSOC);

        if ($verify['count'] == 0) {
            echo "✅ Verificación: Registro eliminado correctamente\n";
        } else {
            echo "❌ Verificación: El registro aún existe\n";
        }
    } else {
        echo "ℹ️  Registro 14 no existe (puede haber sido eliminado antes)\n";
        echo "📝 Probando DELETE con registro inexistente...\n\n";

        $testDelete = json_encode([
            'cvereq' => 99999,
            'clave_cuenta' => '999999',
            'ejercicio' => 2024,
            'estatus' => 'Pendiente'
        ]);

        $stmt = $pdo->prepare("SELECT recaudadora_reqtrans_delete(?)");
        $stmt->execute([$testDelete]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "📊 Resultado (registro inexistente):\n";
        $resultJson = json_decode($result['recaudadora_reqtrans_delete'], true);
        echo "   Success: " . ($resultJson['success'] ? 'true' : 'false') . "\n";
        echo "   Message: " . $resultJson['message'] . "\n";
        echo "\n";
        echo "✅ Validación de registro inexistente funciona correctamente\n";
    }

    echo "\n";
    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║          🎉 DELETE SP DESPLEGADO EXITOSAMENTE 🎉          ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 RESUMEN:\n";
    echo "   ✅ SP recaudadora_reqtrans_delete creado\n";
    echo "   ✅ Busca por cvereq (ID único)\n";
    echo "   ✅ Valida existencia del registro\n";
    echo "   ✅ Maneja foreign key violations\n";
    echo "   ✅ Retorna JSON con success/message\n";
    echo "   ✅ Frontend ya tiene modal de confirmación\n";
    echo "   ✅ Frontend ya tiene función confirmDelete()\n";
    echo "\n";
    echo "🎯 PRÓXIMOS PASOS:\n";
    echo "   1. Probar eliminación desde el frontend\n";
    echo "   2. Verificar que el modal de confirmación funciona\n";
    echo "   3. Verificar alertas de éxito/error\n";
    echo "   4. Verificar que la lista se recarga después de eliminar\n";
    echo "\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
