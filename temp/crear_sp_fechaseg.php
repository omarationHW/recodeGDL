<?php
// Crear SPs para fechas de seguimiento usando tabla existente comun.t42_seguimiento

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SPs PARA FECHAS DE SEGUIMIENTO ===\n\n";

    // DROP funciones existentes
    echo "🗑️  Eliminando funciones existentes...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_list()");
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_get(INTEGER)");
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_create(INTEGER, INTEGER, INTEGER, TIMESTAMP, INTEGER, VARCHAR, VARCHAR)");
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_update(INTEGER, INTEGER, INTEGER, INTEGER, TIMESTAMP, INTEGER, VARCHAR, VARCHAR)");
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_delete(INTEGER)");
    echo "✅ Funciones eliminadas\n\n";

    // 1. SP_FECHASEG_LIST - Listar todas las fechas de seguimiento
    echo "1️⃣  Creando sp_fechaseg_list...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_list()
        RETURNS TABLE (
            id INTEGER,
            t42_doctos_id INTEGER,
            t42_centros_id INTEGER,
            usuario_seg INTEGER,
            fec_seg TIMESTAMP,
            t42_statusseg_id INTEGER,
            observacion VARCHAR,
            usuario_mov CHAR(10)
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                s.id,
                s.t42_doctos_id,
                s.t42_centros_id,
                s.usuario_seg,
                s.fec_seg,
                s.t42_statusseg_id,
                s.observacion,
                s.usuario_mov
            FROM comun.t42_seguimiento s
            ORDER BY s.fec_seg DESC NULLS LAST, s.id DESC
            LIMIT 1000;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_list creado (limitado a 1000 registros más recientes)\n\n";

    // 2. SP_FECHASEG_GET - Obtener una fecha de seguimiento por ID
    echo "2️⃣  Creando sp_fechaseg_get...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_get(p_id INTEGER)
        RETURNS TABLE (
            id INTEGER,
            t42_doctos_id INTEGER,
            t42_centros_id INTEGER,
            usuario_seg INTEGER,
            fec_seg TIMESTAMP,
            t42_statusseg_id INTEGER,
            observacion VARCHAR,
            usuario_mov CHAR(10)
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                s.id,
                s.t42_doctos_id,
                s.t42_centros_id,
                s.usuario_seg,
                s.fec_seg,
                s.t42_statusseg_id,
                s.observacion,
                s.usuario_mov
            FROM comun.t42_seguimiento s
            WHERE s.id = p_id;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_get creado\n\n";

    // 3. SP_FECHASEG_CREATE - Crear nueva fecha de seguimiento
    echo "3️⃣  Creando sp_fechaseg_create...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_create(
            p_t42_doctos_id INTEGER,
            p_t42_centros_id INTEGER,
            p_usuario_seg INTEGER,
            p_fec_seg TIMESTAMP,
            p_t42_statusseg_id INTEGER,
            p_observacion VARCHAR(255),
            p_usuario_mov CHAR(10)
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            id INTEGER
        ) AS $$
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
            RETURNING id INTO v_id;

            RETURN QUERY SELECT TRUE, 'Fecha de seguimiento creada exitosamente'::VARCHAR, v_id;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al crear: ' || SQLERRM)::VARCHAR, NULL::INTEGER;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_create creado\n\n";

    // 4. SP_FECHASEG_UPDATE - Actualizar fecha de seguimiento existente
    echo "4️⃣  Creando sp_fechaseg_update...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_update(
            p_id INTEGER,
            p_t42_doctos_id INTEGER,
            p_t42_centros_id INTEGER,
            p_usuario_seg INTEGER,
            p_fec_seg TIMESTAMP,
            p_t42_statusseg_id INTEGER,
            p_observacion VARCHAR(255),
            p_usuario_mov CHAR(10)
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS $$
        BEGIN
            -- Validaciones
            IF NOT EXISTS (SELECT 1 FROM comun.t42_seguimiento WHERE id = p_id) THEN
                RETURN QUERY SELECT FALSE, 'Fecha de seguimiento no encontrada'::VARCHAR;
                RETURN;
            END IF;

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
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_update creado\n\n";

    // 5. SP_FECHASEG_DELETE - Eliminar fecha de seguimiento
    echo "5️⃣  Creando sp_fechaseg_delete...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_delete(p_id INTEGER)
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS $$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM comun.t42_seguimiento WHERE id = p_id) THEN
                RETURN QUERY SELECT FALSE, 'Fecha de seguimiento no encontrada'::VARCHAR;
                RETURN;
            END IF;

            DELETE FROM comun.t42_seguimiento WHERE id = p_id;

            RETURN QUERY SELECT TRUE, 'Fecha de seguimiento eliminada exitosamente'::VARCHAR;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al eliminar: ' || SQLERRM)::VARCHAR;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_delete creado\n\n";

    // 6. Probar SP
    echo "🧪 Probando sp_fechaseg_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("SELECT * FROM comun.sp_fechaseg_list() LIMIT 5");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Total registros obtenidos: " . count($results) . "\n";
    foreach ($results as $i => $row) {
        if ($i < 3) {
            $fecha = $row['fec_seg'] ?? 'NULL';
            $obs = substr($row['observacion'] ?? '', 0, 40);
            echo ($i + 1) . ". ID: {$row['id']} - Fecha: {$fecha} - Obs: {$obs}\n";
        }
    }
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPs CREADOS EXITOSAMENTE\n";
    echo "\nSPs creados:\n";
    echo "  - sp_fechaseg_list() - Listar fechas (últimas 1000)\n";
    echo "  - sp_fechaseg_get(id) - Obtener por ID\n";
    echo "  - sp_fechaseg_create(...) - Crear nueva\n";
    echo "  - sp_fechaseg_update(...) - Actualizar existente\n";
    echo "  - sp_fechaseg_delete(id) - Eliminar\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
