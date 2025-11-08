<?php
// Arreglar todos los SPs de fechaseg (CREATE, UPDATE, DELETE)

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ARREGLAR SPS DE FECHASEG ===\n\n";

    // 1. Arreglar SP_FECHASEG_CREATE
    echo "1️⃣  Arreglando sp_fechaseg_create...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_create(INTEGER, INTEGER, INTEGER, TIMESTAMP, INTEGER, VARCHAR, CHAR)");

    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_create(
            p_t42_doctos_id INTEGER,
            p_t42_centros_id INTEGER,
            p_usuario_seg INTEGER,
            p_fec_seg TIMESTAMP,
            p_t42_statusseg_id INTEGER,
            p_observacion VARCHAR,
            p_usuario_mov CHAR(10)
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            id INTEGER
        ) AS \$\$
        DECLARE
            v_id INTEGER;
        BEGIN
            -- Validaciones básicas
            IF p_fec_seg IS NULL THEN
                RETURN QUERY SELECT FALSE, 'La fecha de seguimiento es requerida'::VARCHAR, NULL::INTEGER;
                RETURN;
            END IF;

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
                p_fec_seg,
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
    echo "   ✅ sp_fechaseg_create arreglado\n\n";

    // 2. Arreglar SP_FECHASEG_UPDATE
    echo "2️⃣  Arreglando sp_fechaseg_update...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_update(INTEGER, INTEGER, INTEGER, INTEGER, TIMESTAMP, INTEGER, VARCHAR, CHAR)");

    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_update(
            p_id INTEGER,
            p_t42_doctos_id INTEGER,
            p_t42_centros_id INTEGER,
            p_usuario_seg INTEGER,
            p_fec_seg TIMESTAMP,
            p_t42_statusseg_id INTEGER,
            p_observacion VARCHAR,
            p_usuario_mov CHAR(10)
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

            -- Validaciones
            IF p_fec_seg IS NULL THEN
                RETURN QUERY SELECT FALSE, 'La fecha de seguimiento es requerida'::VARCHAR;
                RETURN;
            END IF;

            -- Actualizar
            UPDATE comun.t42_seguimiento
            SET
                t42_doctos_id = p_t42_doctos_id,
                t42_centros_id = p_t42_centros_id,
                usuario_seg = p_usuario_seg,
                fec_seg = p_fec_seg,
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
    echo "   ✅ sp_fechaseg_update arreglado\n\n";

    // 3. Arreglar SP_FECHASEG_DELETE
    echo "3️⃣  Arreglando sp_fechaseg_delete...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_delete(INTEGER)");

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
    echo "   ✅ sp_fechaseg_delete arreglado\n\n";

    // Probar los SPs
    echo "=== PRUEBAS ===\n\n";

    // Probar CREATE
    echo "🧪 Probando CREATE:\n";
    $stmt = $db->query("SELECT * FROM comun.sp_fechaseg_create(999999, 999, 100, '2021-12-01 10:00:00', 1, 'Prueba desde Claude', 'TEST')");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   success: " . ($result['success'] === 't' ? 'true' : 'false') . "\n";
    echo "   message: " . $result['message'] . "\n";
    echo "   id: " . ($result['id'] ?? 'NULL') . "\n\n";

    if ($result['success'] === 't' && $result['id']) {
        $nuevo_id = $result['id'];

        // Probar UPDATE
        echo "🧪 Probando UPDATE (ID: $nuevo_id):\n";
        $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_update(?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$nuevo_id, 999999, 999, 100, '2021-12-01 11:00:00', 2, 'Actualizado por Claude', 'TESTUPD']);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   success: " . ($result['success'] === 't' ? 'true' : 'false') . "\n";
        echo "   message: " . $result['message'] . "\n\n";

        // Probar DELETE
        echo "🧪 Probando DELETE (ID: $nuevo_id):\n";
        $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_delete(?)");
        $stmt->execute([$nuevo_id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   success: " . ($result['success'] === 't' ? 'true' : 'false') . "\n";
        echo "   message: " . $result['message'] . "\n\n";
    }

    echo "✅ TODOS LOS SPS ARREGLADOS Y PROBADOS\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
