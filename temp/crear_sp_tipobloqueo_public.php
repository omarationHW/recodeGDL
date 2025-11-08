<?php
// Crear SPs de tipobloqueo en el esquema 'public'

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SPs EN ESQUEMA 'public' ===\n\n";

    // 1. SP_TIPOBLOQUEO_LIST
    echo "1️⃣  Creando sp_tipobloqueo_list...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_list()
        RETURNS TABLE (
            id INTEGER,
            descripcion VARCHAR,
            sel_cons CHAR
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                c.id,
                TRIM(c.descripcion)::VARCHAR as descripcion,
                c.sel_cons
            FROM public.c_tipobloqueo c
            ORDER BY c.id;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_tipobloqueo_list creado\n\n";

    // 2. SP_TIPOBLOQUEO_GET
    echo "2️⃣  Creando sp_tipobloqueo_get...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_get(p_id INTEGER)
        RETURNS TABLE (
            id INTEGER,
            descripcion VARCHAR,
            sel_cons CHAR
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                c.id,
                TRIM(c.descripcion)::VARCHAR as descripcion,
                c.sel_cons
            FROM public.c_tipobloqueo c
            WHERE c.id = p_id;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_tipobloqueo_get creado\n\n";

    // 3. SP_TIPOBLOQUEO_CREATE
    echo "3️⃣  Creando sp_tipobloqueo_create...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_create(
            p_descripcion VARCHAR,
            p_sel_cons CHAR DEFAULT 'S'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            id INTEGER
        ) AS \$\$
        DECLARE
            v_new_id INTEGER;
        BEGIN
            -- Obtener el siguiente ID
            SELECT COALESCE(MAX(c.id), 0) + 1 INTO v_new_id
            FROM public.c_tipobloqueo c;

            -- Insertar
            INSERT INTO public.c_tipobloqueo (id, descripcion, sel_cons)
            VALUES (v_new_id, p_descripcion, p_sel_cons);

            RETURN QUERY
            SELECT
                TRUE as success,
                'Tipo de bloqueo creado exitosamente'::VARCHAR as message,
                v_new_id as id;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al crear tipo: ' || SQLERRM)::VARCHAR as message,
                    NULL::INTEGER as id;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_tipobloqueo_create creado\n\n";

    // 4. SP_TIPOBLOQUEO_UPDATE
    echo "4️⃣  Creando sp_tipobloqueo_update...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_update(
            p_id INTEGER,
            p_descripcion VARCHAR,
            p_sel_cons CHAR
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM public.c_tipobloqueo WHERE id = p_id) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Tipo de bloqueo no encontrado'::VARCHAR as message;
                RETURN;
            END IF;

            -- Actualizar
            UPDATE public.c_tipobloqueo
            SET
                descripcion = p_descripcion,
                sel_cons = p_sel_cons
            WHERE id = p_id;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Tipo de bloqueo actualizado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al actualizar tipo: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_tipobloqueo_update creado\n\n";

    // 5. SP_TIPOBLOQUEO_DELETE
    echo "5️⃣  Creando sp_tipobloqueo_delete...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_delete(p_id INTEGER)
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM public.c_tipobloqueo WHERE id = p_id) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Tipo de bloqueo no encontrado'::VARCHAR as message;
                RETURN;
            END IF;

            -- Eliminar
            DELETE FROM public.c_tipobloqueo WHERE id = p_id;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Tipo de bloqueo eliminado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al eliminar tipo: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_tipobloqueo_delete creado\n\n";

    // Probar el SP de listar
    echo "🧪 Probando sp_tipobloqueo_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query('SELECT * FROM public.sp_tipobloqueo_list() LIMIT 5');
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Primeros 5 registros:\n";
    print_r($results);
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPs CREADOS EXITOSAMENTE EN 'public'\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
