<?php
// Crear SPs para dependencias en esquema 'comun'

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SPs PARA CATÁLOGO DE DEPENDENCIAS ===\n\n";

    // 1. SP_DEPENDENCIAS_LIST
    echo "1️⃣  Creando sp_dependencias_list...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_dependencias_list()
        RETURNS TABLE (
            id_dependencia INTEGER,
            dependencia VARCHAR,
            id_depref INTEGER,
            estado VARCHAR,
            fecha_mov DATE
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                d.id_dependencia,
                TRIM(d.dependencia)::VARCHAR as dependencia,
                d.id_depref,
                TRIM(d.estado)::VARCHAR as estado,
                d.fecha_mov
            FROM comun.ta_dependencias d
            ORDER BY d.id_dependencia;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_dependencias_list creado\n\n";

    // 2. SP_DEPENDENCIAS_GET
    echo "2️⃣  Creando sp_dependencias_get...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_dependencias_get(p_id_dependencia INTEGER)
        RETURNS TABLE (
            id_dependencia INTEGER,
            dependencia VARCHAR,
            id_depref INTEGER,
            estado VARCHAR,
            fecha_mov DATE
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                d.id_dependencia,
                TRIM(d.dependencia)::VARCHAR as dependencia,
                d.id_depref,
                TRIM(d.estado)::VARCHAR as estado,
                d.fecha_mov
            FROM comun.ta_dependencias d
            WHERE d.id_dependencia = p_id_dependencia;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_dependencias_get creado\n\n";

    // 3. SP_DEPENDENCIAS_CREATE
    echo "3️⃣  Creando sp_dependencias_create...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_dependencias_create(
            p_id_dependencia INTEGER,
            p_dependencia VARCHAR,
            p_id_depref INTEGER DEFAULT 0,
            p_estado VARCHAR DEFAULT 'A'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            id_dependencia INTEGER
        ) AS $$
        DECLARE
            v_fecha_mov DATE := CURRENT_DATE;
        BEGIN
            -- Verificar si ya existe
            IF EXISTS (SELECT 1 FROM comun.ta_dependencias WHERE id_dependencia = p_id_dependencia) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Ya existe una dependencia con ese ID'::VARCHAR as message,
                    NULL::INTEGER as id_dependencia;
                RETURN;
            END IF;

            -- Insertar
            INSERT INTO comun.ta_dependencias (id_dependencia, dependencia, id_depref, estado, fecha_mov)
            VALUES (p_id_dependencia, p_dependencia, p_id_depref, p_estado, v_fecha_mov);

            RETURN QUERY
            SELECT
                TRUE as success,
                'Dependencia creada exitosamente'::VARCHAR as message,
                p_id_dependencia as id_dependencia;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al crear dependencia: ' || SQLERRM)::VARCHAR as message,
                    NULL::INTEGER as id_dependencia;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_dependencias_create creado\n\n";

    // 4. SP_DEPENDENCIAS_UPDATE
    echo "4️⃣  Creando sp_dependencias_update...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_dependencias_update(
            p_id_dependencia INTEGER,
            p_dependencia VARCHAR,
            p_id_depref INTEGER,
            p_estado VARCHAR
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS $$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM comun.ta_dependencias WHERE id_dependencia = p_id_dependencia) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Dependencia no encontrada'::VARCHAR as message;
                RETURN;
            END IF;

            -- Actualizar
            UPDATE comun.ta_dependencias
            SET
                dependencia = p_dependencia,
                id_depref = p_id_depref,
                estado = p_estado,
                fecha_mov = CURRENT_DATE
            WHERE id_dependencia = p_id_dependencia;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Dependencia actualizada exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al actualizar dependencia: ' || SQLERRM)::VARCHAR as message;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_dependencias_update creado\n\n";

    // 5. SP_DEPENDENCIAS_DELETE
    echo "5️⃣  Creando sp_dependencias_delete...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_dependencias_delete(p_id_dependencia INTEGER)
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS $$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM comun.ta_dependencias WHERE id_dependencia = p_id_dependencia) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Dependencia no encontrada'::VARCHAR as message;
                RETURN;
            END IF;

            -- Eliminar
            DELETE FROM comun.ta_dependencias WHERE id_dependencia = p_id_dependencia;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Dependencia eliminada exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al eliminar dependencia: ' || SQLERRM)::VARCHAR as message;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_dependencias_delete creado\n\n";

    // Probar el SP de listar
    echo "🧪 Probando sp_dependencias_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query('SELECT * FROM comun.sp_dependencias_list() LIMIT 5');
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Primeros 5 registros:\n";
    foreach ($results as $i => $row) {
        echo ($i + 1) . ". ID: {$row['id_dependencia']} - {$row['dependencia']} - Estado: {$row['estado']}\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPs CREADOS EXITOSAMENTE EN 'comun'\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
