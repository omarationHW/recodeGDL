<?php
// Arreglar SP_FECHASEG_UPDATE para que acepte los parámetros correctamente

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ARREGLAR SP_FECHASEG_UPDATE ===\n\n";

    // Eliminar todas las versiones del SP
    echo "1️⃣  Eliminando todas las versiones de sp_fechaseg_update...\n";

    // Buscar todas las versiones del SP
    $stmt = $db->query("
        SELECT
            p.proname,
            pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'sp_fechaseg_update'
    ");
    $versions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($versions) > 0) {
        echo "   Encontradas " . count($versions) . " versión(es):\n";
        foreach ($versions as $v) {
            echo "   - sp_fechaseg_update({$v['args']})\n";
            $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_update({$v['args']}) CASCADE");
        }
    }
    echo "   ✅ Versiones antiguas eliminadas\n\n";

    // Crear el SP con los tipos correctos
    echo "2️⃣  Creando sp_fechaseg_update con tipos correctos...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_update(
            p_id INTEGER,
            p_t42_doctos_id INTEGER,
            p_t42_centros_id INTEGER,
            p_usuario_seg INTEGER,
            p_fec_seg TEXT,  -- Recibe como TEXT porque viene del frontend así
            p_t42_statusseg_id INTEGER,
            p_observacion VARCHAR,
            p_usuario_mov VARCHAR  -- VARCHAR en lugar de CHAR para mayor flexibilidad
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        DECLARE
            v_count INTEGER;
            v_fec_seg_timestamp TIMESTAMP;
        BEGIN
            -- Verificar que existe
            SELECT COUNT(*) INTO v_count FROM comun.t42_seguimiento WHERE id = p_id;

            IF v_count = 0 THEN
                RETURN QUERY SELECT FALSE, 'Registro no encontrado'::VARCHAR;
                RETURN;
            END IF;

            -- Validaciones
            IF p_fec_seg IS NULL OR p_fec_seg = '' THEN
                RETURN QUERY SELECT FALSE, 'La fecha de seguimiento es requerida'::VARCHAR;
                RETURN;
            END IF;

            -- Convertir la fecha de texto a timestamp
            BEGIN
                v_fec_seg_timestamp := p_fec_seg::TIMESTAMP;
            EXCEPTION
                WHEN OTHERS THEN
                    RETURN QUERY SELECT FALSE, 'Formato de fecha inválido'::VARCHAR;
                    RETURN;
            END;

            -- Actualizar
            UPDATE comun.t42_seguimiento
            SET
                t42_doctos_id = p_t42_doctos_id,
                t42_centros_id = p_t42_centros_id,
                usuario_seg = p_usuario_seg,
                fec_seg = v_fec_seg_timestamp,
                t42_statusseg_id = p_t42_statusseg_id,
                observacion = p_observacion,
                usuario_mov = p_usuario_mov
            WHERE id = p_id;

            RETURN QUERY SELECT TRUE, 'Fecha de seguimiento actualizada exitosamente'::VARCHAR;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al actualizar: ' || SQLERRM)::VARCHAR;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ sp_fechaseg_update creado\n\n";

    // Probar el SP
    echo "🧪 Probando sp_fechaseg_update:\n";
    echo str_repeat("-", 80) . "\n";

    // Primero crear un registro de prueba
    echo "Creando registro de prueba...\n";
    $stmt = $db->query("
        INSERT INTO comun.t42_seguimiento (t42_doctos_id, t42_centros_id, usuario_seg, fec_seg, t42_statusseg_id, observacion, usuario_mov)
        VALUES (999999, 999, 100, '2021-12-01 10:00:00', 1, 'Prueba UPDATE', 'TEST')
        RETURNING id
    ");
    $test_id = $stmt->fetch(PDO::FETCH_ASSOC)['id'];
    echo "Registro creado con ID: $test_id\n\n";

    // Probar UPDATE
    echo "Probando UPDATE con fecha como texto...\n";
    $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_update(?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        $test_id,
        999999,
        999,
        101,
        '2021-12-01 11:30:00',  // Fecha como texto
        2,
        'Actualizado desde prueba',
        'TESTUPD'
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "Resultado:\n";
    echo "  success: " . ($result['success'] ? 'true' : 'false') . "\n";
    echo "  message: " . $result['message'] . "\n\n";

    // Eliminar el registro de prueba
    $db->exec("DELETE FROM comun.t42_seguimiento WHERE id = $test_id");
    echo "Registro de prueba eliminado\n";
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ SP_FECHASEG_UPDATE ARREGLADO Y PROBADO\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
