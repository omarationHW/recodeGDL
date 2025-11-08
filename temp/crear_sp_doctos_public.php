<?php
// Crear SPs para c_doctos en esquema 'public'

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SPs PARA CATÁLOGO DE DOCUMENTOS ===\n\n";

    // 1. SP_DOCTOS_LIST
    echo "1️⃣  Creando sp_doctos_list...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_doctos_list()
        RETURNS TABLE (
            cvedocto INTEGER,
            documento VARCHAR,
            feccap DATE,
            capturista VARCHAR
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                d.cvedocto,
                TRIM(d.documento)::VARCHAR as documento,
                d.feccap,
                TRIM(d.capturista)::VARCHAR as capturista
            FROM public.c_doctos d
            ORDER BY d.cvedocto;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_doctos_list creado\n\n";

    // 2. SP_DOCTOS_GET
    echo "2️⃣  Creando sp_doctos_get...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_doctos_get(p_cvedocto INTEGER)
        RETURNS TABLE (
            cvedocto INTEGER,
            documento VARCHAR,
            feccap DATE,
            capturista VARCHAR
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                d.cvedocto,
                TRIM(d.documento)::VARCHAR as documento,
                d.feccap,
                TRIM(d.capturista)::VARCHAR as capturista
            FROM public.c_doctos d
            WHERE d.cvedocto = p_cvedocto;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_doctos_get creado\n\n";

    // 3. SP_DOCTOS_CREATE
    echo "3️⃣  Creando sp_doctos_create...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_doctos_create(
            p_cvedocto INTEGER,
            p_documento VARCHAR,
            p_capturista VARCHAR DEFAULT 'sistema'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            cvedocto INTEGER
        ) AS \$\$
        DECLARE
            v_feccap DATE := CURRENT_DATE;
        BEGIN
            -- Verificar si ya existe
            IF EXISTS (SELECT 1 FROM public.c_doctos WHERE cvedocto = p_cvedocto) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Ya existe un documento con esa clave'::VARCHAR as message,
                    NULL::INTEGER as cvedocto;
                RETURN;
            END IF;

            -- Insertar
            INSERT INTO public.c_doctos (cvedocto, documento, feccap, capturista)
            VALUES (p_cvedocto, p_documento, v_feccap, p_capturista);

            RETURN QUERY
            SELECT
                TRUE as success,
                'Documento creado exitosamente'::VARCHAR as message,
                p_cvedocto as cvedocto;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al crear documento: ' || SQLERRM)::VARCHAR as message,
                    NULL::INTEGER as cvedocto;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_doctos_create creado\n\n";

    // 4. SP_DOCTOS_UPDATE
    echo "4️⃣  Creando sp_doctos_update...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_doctos_update(
            p_cvedocto INTEGER,
            p_documento VARCHAR,
            p_capturista VARCHAR DEFAULT 'sistema'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM public.c_doctos WHERE cvedocto = p_cvedocto) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Documento no encontrado'::VARCHAR as message;
                RETURN;
            END IF;

            -- Actualizar
            UPDATE public.c_doctos
            SET
                documento = p_documento,
                feccap = CURRENT_DATE,
                capturista = p_capturista
            WHERE cvedocto = p_cvedocto;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Documento actualizado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al actualizar documento: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_doctos_update creado\n\n";

    // 5. SP_DOCTOS_DELETE
    echo "5️⃣  Creando sp_doctos_delete...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_doctos_delete(p_cvedocto INTEGER)
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM public.c_doctos WHERE cvedocto = p_cvedocto) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Documento no encontrado'::VARCHAR as message;
                RETURN;
            END IF;

            -- Eliminar
            DELETE FROM public.c_doctos WHERE cvedocto = p_cvedocto;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Documento eliminado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al eliminar documento: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_doctos_delete creado\n\n";

    // Probar el SP de listar
    echo "🧪 Probando sp_doctos_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query('SELECT * FROM public.sp_doctos_list() LIMIT 5');
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Primeros 5 registros:\n";
    foreach ($results as $i => $row) {
        echo ($i + 1) . ". Clave: {$row['cvedocto']} - {$row['documento']}\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPs CREADOS EXITOSAMENTE EN 'public'\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
