-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_abc_propietario
-- Generado: 2025-08-27 14:05:45
-- Total SPs: 2
-- ============================================

-- SP 1/2: check_rfc_exists
-- Tipo: Catalog
-- Descripción: Verifica si un RFC ya existe en la tabla ta14_personas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION check_rfc_exists(p_rfc VARCHAR)
RETURNS TABLE (exists BOOLEAN)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT EXISTS(SELECT 1 FROM ta14_personas WHERE rfc = UPPER(TRIM(p_rfc)));
END;
$$;

-- ============================================

-- SP 2/2: insert_persona
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en ta14_personas si el RFC no existe. Devuelve el id y mensaje.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION insert_persona(
    p_nombre VARCHAR,
    p_ap_pater VARCHAR DEFAULT NULL,
    p_ap_mater VARCHAR DEFAULT NULL,
    p_rfc VARCHAR,
    p_ife VARCHAR DEFAULT NULL,
    p_sociedad CHAR(1),
    p_direccion VARCHAR DEFAULT NULL,
    p_usu_inicial INTEGER
)
RETURNS TABLE (id_esta_persona INTEGER, msg TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists BOOLEAN;
    v_id INTEGER;
BEGIN
    SELECT EXISTS(SELECT 1 FROM ta14_personas WHERE rfc = UPPER(TRIM(p_rfc))) INTO v_exists;
    IF v_exists THEN
        RETURN QUERY SELECT NULL::INTEGER, 'Este RFC ya está registrado.';
        RETURN;
    END IF;
    INSERT INTO ta14_personas (
        fecha_inicial, nombre, ap_pater, ap_mater, rfc, ife, sociedad, direccion, usu_inicial
    ) VALUES (
        CURRENT_DATE, UPPER(TRIM(p_nombre)), UPPER(TRIM(p_ap_pater)), UPPER(TRIM(p_ap_mater)),
        UPPER(TRIM(p_rfc)), UPPER(TRIM(p_ife)), p_sociedad, COALESCE(p_direccion, ''), p_usu_inicial
    ) RETURNING id_esta_persona INTO v_id;
    RETURN QUERY SELECT v_id, 'Fue dado de alta el registro';
END;
$$;

-- ============================================

