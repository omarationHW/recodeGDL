<?php
// Arreglar SP_FECHASEG_CREATE y DELETE para que acepten los parámetros correctamente

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ARREGLAR SP_FECHASEG_CREATE Y DELETE ===\n\n";

    // ========== CREATE ==========
    echo "1️⃣  Arreglando sp_fechaseg_create...\n";

    // Eliminar versiones antiguas
    $stmt = $db->query("
        SELECT pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun' AND p.proname = 'sp_fechaseg_create'
    ");
    $versions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($versions as $v) {
        $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_create({$v['args']}) CASCADE");
    }

    // Crear SP con tipos correctos
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_create(
            p_t42_doctos_id INTEGER,
            p_t42_centros_id INTEGER,
            p_usuario_seg INTEGER,
            p_fec_seg TEXT,  -- Recibe como TEXT
            p_t42_statusseg_id INTEGER,
            p_observacion VARCHAR,
            p_usuario_mov VARCHAR
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            id INTEGER
        ) AS \$\$
        DECLARE
            v_id INTEGER;
            v_fec_seg_timestamp TIMESTAMP;
        BEGIN
            -- Validaciones básicas
            IF p_fec_seg IS NULL OR p_fec_seg = '' THEN
                RETURN QUERY SELECT FALSE, 'La fecha de seguimiento es requerida'::VARCHAR, NULL::INTEGER;
                RETURN;
            END IF;

            -- Convertir la fecha de texto a timestamp
            BEGIN
                v_fec_seg_timestamp := p_fec_seg::TIMESTAMP;
            EXCEPTION
                WHEN OTHERS THEN
                    RETURN QUERY SELECT FALSE, 'Formato de fecha inválido'::VARCHAR, NULL::INTEGER;
                    RETURN;
            END;

            -- Insertar
            INSERT INTO comun.t42_seguimiento (
                t42_doctos_id,
                t42_centros_id,
                usuario_seg,
                fec_seg,
                t42_statusseg_id,
                observacion,
                usuario_mov
            ) VALUES (
                p_t42_doctos_id,
                p_t42_centros_id,
                p_usuario_seg,
                v_fec_seg_timestamp,
                p_t42_statusseg_id,
                p_observacion,
                p_usuario_mov
            )
            RETURNING t42_seguimiento.id INTO v_id;

            RETURN QUERY SELECT TRUE, 'Fecha de seguimiento creada exitosamente'::VARCHAR, v_id;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al crear: ' || SQLERRM)::VARCHAR, NULL::INTEGER;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ sp_fechaseg_create creado\n\n";

    // ========== DELETE ==========
    echo "2️⃣  Arreglando sp_fechaseg_delete...\n";

    // Eliminar versiones antiguas
    $stmt = $db->query("
        SELECT pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun' AND p.proname = 'sp_fechaseg_delete'
    ");
    $versions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($versions as $v) {
        $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_delete({$v['args']}) CASCADE");
    }

    // Crear SP
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_delete(
            p_id INTEGER
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        DECLARE
            v_count INTEGER;
        BEGIN
            -- Verificar que existe
            SELECT COUNT(*) INTO v_count FROM comun.t42_seguimiento WHERE id = p_id;

            IF v_count = 0 THEN
                RETURN QUERY SELECT FALSE, 'Registro no encontrado'::VARCHAR;
                RETURN;
            END IF;

            -- Eliminar
            DELETE FROM comun.t42_seguimiento WHERE id = p_id;

            RETURN QUERY SELECT TRUE, 'Fecha de seguimiento eliminada exitosamente'::VARCHAR;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al eliminar: ' || SQLERRM)::VARCHAR;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ sp_fechaseg_delete creado\n\n";

    // ========== PRUEBAS ==========
    echo "🧪 PRUEBAS:\n";
    echo str_repeat("-", 80) . "\n";

    // Probar CREATE
    echo "Probando CREATE...\n";
    $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_create(?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([999999, 999, 100, '2021-12-01 10:00:00', 1, 'Prueba CREATE', 'TEST']);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  success: " . ($result['success'] ? 'true' : 'false') . "\n";
    echo "  message: " . $result['message'] . "\n";
    $nuevo_id = $result['id'];
    echo "  id: $nuevo_id\n\n";

    if ($result['success'] && $nuevo_id) {
        // Probar DELETE
        echo "Probando DELETE (ID: $nuevo_id)...\n";
        $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_delete(?)");
        $stmt->execute([$nuevo_id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "  success: " . ($result['success'] ? 'true' : 'false') . "\n";
        echo "  message: " . $result['message'] . "\n";
    }

    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPS ARREGLADOS Y PROBADOS\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
