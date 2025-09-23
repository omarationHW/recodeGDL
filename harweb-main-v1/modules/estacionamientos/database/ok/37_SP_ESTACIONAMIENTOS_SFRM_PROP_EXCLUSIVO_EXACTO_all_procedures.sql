-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_PROP_EXCLUSIVO (EXACTO del archivo original)
-- Archivo: 37_SP_ESTACIONAMIENTOS_SFRM_PROP_EXCLUSIVO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: ex_propietario_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en ex_propietario si el RFC no existe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION ex_propietario_create(
    p_sociedad CHAR(1),
    p_rfc VARCHAR(13),
    p_propietario VARCHAR(255),
    p_domicilio VARCHAR(60),
    p_colonia VARCHAR(50),
    p_telefono VARCHAR(15),
    p_celular VARCHAR(15),
    p_email VARCHAR(60)
) RETURNS TABLE(success boolean, message text, id integer) AS $$
DECLARE
    v_exists integer;
    v_id integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ex_propietario WHERE rfc = p_rfc;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Este RFC ya está registrado.', NULL;
        RETURN;
    END IF;
    INSERT INTO ex_propietario (sociedad, rfc, propietario, domicilio, colonia, telefono, celular, email, fecha_in)
    VALUES (p_sociedad, p_rfc, p_propietario, p_domicilio, p_colonia, p_telefono, p_celular, p_email, CURRENT_DATE)
    RETURNING id INTO v_id;
    RETURN QUERY SELECT true, 'Fue dado de alta el registro.', v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_PROP_EXCLUSIVO (EXACTO del archivo original)
-- Archivo: 37_SP_ESTACIONAMIENTOS_SFRM_PROP_EXCLUSIVO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: ex_propietario_by_rfc
-- Tipo: Catalog
-- Descripción: Obtiene registros de ex_propietario por RFC.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION ex_propietario_by_rfc(p_rfc VARCHAR(13))
RETURNS TABLE(
    id integer,
    rfc varchar,
    sociedad char(1),
    propietario varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    celular varchar,
    email varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, rfc, sociedad, propietario, domicilio, colonia, telefono, celular, email
    FROM ex_propietario
    WHERE rfc = p_rfc;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_PROP_EXCLUSIVO (EXACTO del archivo original)
-- Archivo: 37_SP_ESTACIONAMIENTOS_SFRM_PROP_EXCLUSIVO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

