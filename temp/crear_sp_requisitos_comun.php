<?php
// Crear SPs para requisitos_doc en esquema 'comun'

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->exec("SET search_path TO comun, public");

    echo "=== CREAR SPs PARA REQUISITOS ===\n\n";

    // 1. SP_CAT_REQUISITOS_LIST
    echo "1️⃣  Creando sp_cat_requisitos_list...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_cat_requisitos_list()
        RETURNS TABLE (
            id_requisito INTEGER,
            descripcion VARCHAR,
            requisitos TEXT
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                r.id_requisito,
                TRIM(r.descripcion)::VARCHAR as descripcion,
                r.requisitos
            FROM comun.requisitos_doc r
            ORDER BY r.id_requisito;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_cat_requisitos_list creado\n\n";

    // 2. SP_CAT_REQUISITOS_GET
    echo "2️⃣  Creando sp_cat_requisitos_get...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_cat_requisitos_get(p_id_requisito INTEGER)
        RETURNS TABLE (
            id_requisito INTEGER,
            descripcion VARCHAR,
            requisitos TEXT
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                r.id_requisito,
                TRIM(r.descripcion)::VARCHAR as descripcion,
                r.requisitos
            FROM comun.requisitos_doc r
            WHERE r.id_requisito = p_id_requisito;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_cat_requisitos_get creado\n\n";

    // 3. SP_CAT_REQUISITOS_CREATE
    echo "3️⃣  Creando sp_cat_requisitos_create...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_cat_requisitos_create(
            p_id_requisito INTEGER,
            p_descripcion VARCHAR,
            p_requisitos TEXT DEFAULT ''
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si ya existe
            IF EXISTS (SELECT 1 FROM comun.requisitos_doc WHERE id_requisito = p_id_requisito) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Ya existe un requisito con ese ID'::VARCHAR as message;
                RETURN;
            END IF;

            -- Insertar
            INSERT INTO comun.requisitos_doc (id_requisito, descripcion, requisitos)
            VALUES (p_id_requisito, p_descripcion, p_requisitos);

            RETURN QUERY
            SELECT
                TRUE as success,
                'Requisito creado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al crear requisito: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_cat_requisitos_create creado\n\n";

    // 4. SP_CAT_REQUISITOS_UPDATE
    echo "4️⃣  Creando sp_cat_requisitos_update...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_cat_requisitos_update(
            p_id_requisito INTEGER,
            p_descripcion VARCHAR,
            p_requisitos TEXT
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM comun.requisitos_doc WHERE id_requisito = p_id_requisito) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Requisito no encontrado'::VARCHAR as message;
                RETURN;
            END IF;

            -- Actualizar
            UPDATE comun.requisitos_doc
            SET
                descripcion = p_descripcion,
                requisitos = p_requisitos
            WHERE id_requisito = p_id_requisito;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Requisito actualizado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al actualizar requisito: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_cat_requisitos_update creado\n\n";

    // 5. SP_CAT_REQUISITOS_DELETE
    echo "5️⃣  Creando sp_cat_requisitos_delete...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_cat_requisitos_delete(p_id_requisito INTEGER)
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        BEGIN
            -- Verificar si existe
            IF NOT EXISTS (SELECT 1 FROM comun.requisitos_doc WHERE id_requisito = p_id_requisito) THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    'Requisito no encontrado'::VARCHAR as message;
                RETURN;
            END IF;

            -- Eliminar
            DELETE FROM comun.requisitos_doc WHERE id_requisito = p_id_requisito;

            RETURN QUERY
            SELECT
                TRUE as success,
                'Requisito eliminado exitosamente'::VARCHAR as message;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY
                SELECT
                    FALSE as success,
                    ('Error al eliminar requisito: ' || SQLERRM)::VARCHAR as message;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_cat_requisitos_delete creado\n\n";

    // Probar el SP de listar
    echo "🧪 Probando sp_cat_requisitos_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query('SELECT * FROM comun.sp_cat_requisitos_list() LIMIT 5');
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Primeros 5 registros:\n";
    foreach ($results as $i => $row) {
        echo ($i + 1) . ". ID: {$row['id_requisito']} - " . substr($row['descripcion'], 0, 60) . "...\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPs CREADOS EXITOSAMENTE EN 'comun'\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
