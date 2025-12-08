-- ============================================
-- STORED PROCEDURES PARA centrosfrm.vue
-- Módulo: multas_reglamentos
-- Fecha: 2025-11-25
-- Descripción: SPs para catálogo de centros
-- ============================================

-- ============================================
-- SP 1/4: centrosfrm_sp_list
-- Lista centros con filtros opcionales
-- ============================================
DROP FUNCTION IF EXISTS centrosfrm_sp_list(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION centrosfrm_sp_list(
    p_q VARCHAR DEFAULT '',
    p_estado VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_centro INTEGER,
    clave INTEGER,
    nombre VARCHAR,
    direccion VARCHAR,
    telefono VARCHAR,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id::INTEGER AS id_centro,
        c.numero::INTEGER AS clave,
        c.nombre::VARCHAR,
        COALESCE(c.domicilio, '')::VARCHAR AS direccion,
        COALESCE(c.abreviatura, '')::VARCHAR AS telefono,
        (COALESCE(c.t42_status_id, 1) = 1)::BOOLEAN AS activo
    FROM comun.t42_centros c
    WHERE
        (p_q = '' OR c.nombre ILIKE '%' || p_q || '%' OR c.numero::TEXT LIKE '%' || p_q || '%')
        AND (p_estado = '' OR
             (p_estado = 'activo' AND COALESCE(c.t42_status_id, 1) = 1) OR
             (p_estado = 'inactivo' AND COALESCE(c.t42_status_id, 1) != 1))
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION centrosfrm_sp_list(VARCHAR, VARCHAR) IS 'Lista centros de recaudación con filtros';

-- ============================================
-- SP 2/4: centrosfrm_sp_create
-- Crea un nuevo centro
-- ============================================
DROP FUNCTION IF EXISTS centrosfrm_sp_create(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION centrosfrm_sp_create(
    p_id_centro INTEGER DEFAULT 0,
    p_clave INTEGER DEFAULT 0,
    p_nombre VARCHAR DEFAULT '',
    p_direccion VARCHAR DEFAULT '',
    p_telefono VARCHAR DEFAULT '',
    p_activo BOOLEAN DEFAULT TRUE
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    id INTEGER
) AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    -- Validar que no exista la clave
    IF EXISTS (SELECT 1 FROM comun.t42_centros WHERE numero = p_clave) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un centro con esa clave'::VARCHAR, 0;
        RETURN;
    END IF;

    -- Obtener siguiente ID
    SELECT COALESCE(MAX(id), 0) + 1 INTO v_new_id FROM comun.t42_centros;

    -- Insertar
    INSERT INTO comun.t42_centros (id, numero, nombre, domicilio, abreviatura, t42_status_id, fec_mov)
    VALUES (v_new_id, p_clave, p_nombre, p_direccion, p_telefono, CASE WHEN p_activo THEN 1 ELSE 0 END, NOW());

    RETURN QUERY SELECT TRUE, 'Centro creado correctamente'::VARCHAR, v_new_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION centrosfrm_sp_create(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, BOOLEAN) IS 'Crea un nuevo centro';

-- ============================================
-- SP 3/4: centrosfrm_sp_update
-- Actualiza un centro existente
-- ============================================
DROP FUNCTION IF EXISTS centrosfrm_sp_update(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION centrosfrm_sp_update(
    p_id_centro INTEGER,
    p_clave INTEGER DEFAULT 0,
    p_nombre VARCHAR DEFAULT '',
    p_direccion VARCHAR DEFAULT '',
    p_telefono VARCHAR DEFAULT '',
    p_activo BOOLEAN DEFAULT TRUE
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    rows_affected INTEGER
) AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    -- Validar que exista
    IF NOT EXISTS (SELECT 1 FROM comun.t42_centros WHERE id = p_id_centro) THEN
        RETURN QUERY SELECT FALSE, 'El centro no existe'::VARCHAR, 0;
        RETURN;
    END IF;

    -- Actualizar
    UPDATE comun.t42_centros
    SET
        nombre = p_nombre,
        domicilio = p_direccion,
        abreviatura = p_telefono,
        t42_status_id = CASE WHEN p_activo THEN 1 ELSE 0 END,
        fec_mov = NOW()
    WHERE id = p_id_centro;

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    RETURN QUERY SELECT TRUE, 'Centro actualizado correctamente'::VARCHAR, v_rows;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION centrosfrm_sp_update(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, BOOLEAN) IS 'Actualiza un centro existente';

-- ============================================
-- SP 4/4: centrosfrm_sp_cambiar_estado
-- Cambia estado activo/inactivo de un centro
-- ============================================
DROP FUNCTION IF EXISTS centrosfrm_sp_cambiar_estado(INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION centrosfrm_sp_cambiar_estado(
    p_id_centro INTEGER,
    p_activo BOOLEAN
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Validar que exista
    IF NOT EXISTS (SELECT 1 FROM comun.t42_centros WHERE id = p_id_centro) THEN
        RETURN QUERY SELECT FALSE, 'El centro no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar estado
    UPDATE comun.t42_centros
    SET
        t42_status_id = CASE WHEN p_activo THEN 1 ELSE 0 END,
        fec_mov = NOW()
    WHERE id = p_id_centro;

    RETURN QUERY SELECT TRUE, ('Centro ' || CASE WHEN p_activo THEN 'activado' ELSE 'desactivado' END || ' correctamente')::VARCHAR;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION centrosfrm_sp_cambiar_estado(INTEGER, BOOLEAN) IS 'Cambia estado activo/inactivo de un centro';

-- ============================================
-- Verificación
-- ============================================
SELECT 'SPs centrosfrm creados correctamente' AS status;
