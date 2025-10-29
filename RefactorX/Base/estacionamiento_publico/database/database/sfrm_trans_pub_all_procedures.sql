-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_trans_pub
-- Generado: 2025-08-27 14:38:19
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_ta_15_publicos_insert
-- Tipo: CRUD
-- Descripción: Inserta un registro en la tabla ta_15_publicos con todos los campos requeridos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ta_15_publicos_insert(
    p_cve_sector VARCHAR,
    p_cve_categ VARCHAR,
    p_cve_numero VARCHAR,
    p_nombre VARCHAR,
    p_telefono VARCHAR,
    p_calle VARCHAR,
    p_num VARCHAR,
    p_cupo VARCHAR,
    p_fecha_alta VARCHAR,
    p_fecha_inic VARCHAR,
    p_fecha_venci VARCHAR,
    p_delas VARCHAR,
    p_alas VARCHAR,
    p_delas1 VARCHAR,
    p_alas1 VARCHAR,
    p_frec_lunes VARCHAR,
    p_frec_martes VARCHAR,
    p_frec_miercoles VARCHAR,
    p_frec_jueves VARCHAR,
    p_frec_viernes VARCHAR,
    p_frec_sabado VARCHAR,
    p_frec_domingo VARCHAR,
    p_pol_num VARCHAR,
    p_pol_fec_ven VARCHAR,
    p_numlic VARCHAR,
    p_zona VARCHAR,
    p_subzona VARCHAR,
    p_estatus VARCHAR,
    p_clave VARCHAR,
    p_control INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    v_fecha_alta DATE;
    v_fecha_inic DATE;
    v_fecha_venci DATE;
    v_pol_fec_ven DATE;
BEGIN
    -- Parse fechas
    IF p_fecha_alta IS NULL OR p_fecha_alta = '00/00/00' THEN
        v_fecha_alta := NULL;
    ELSE
        v_fecha_alta := to_date(p_fecha_alta, 'DD/MM/YY');
    END IF;
    IF p_fecha_inic IS NULL OR p_fecha_inic = '00/00/00' THEN
        v_fecha_inic := NULL;
    ELSE
        v_fecha_inic := to_date(p_fecha_inic, 'DD/MM/YY');
    END IF;
    IF p_fecha_venci IS NULL OR p_fecha_venci = '00/00/00' THEN
        v_fecha_venci := NULL;
    ELSE
        v_fecha_venci := to_date(p_fecha_venci, 'DD/MM/YY');
    END IF;
    IF p_pol_fec_ven IS NULL OR p_pol_fec_ven = '00/00/00' THEN
        v_pol_fec_ven := NULL;
    ELSE
        v_pol_fec_ven := to_date(p_pol_fec_ven, 'DD/MM/YY');
    END IF;
    INSERT INTO ta_15_publicos (
        control, cve_sector, cve_categ, cve_numero, nombre, telefono, calle, num, cupo, fecha_alta, fecha_inic, fecha_venci, delas, alas, delas1, alas1, frec_lunes, frec_martes, frec_miercoles, frec_jueves, frec_viernes, frec_sabado, frec_domingo, pol_num, pol_fec_ven, numlic, zona, subzona, estatus, clave
    ) VALUES (
        p_control, p_cve_sector, p_cve_categ, p_cve_numero, p_nombre, p_telefono, p_calle, p_num, NULLIF(p_cupo, '')::INTEGER, v_fecha_alta, v_fecha_inic, v_fecha_venci, NULLIF(p_delas, '')::INTEGER, NULLIF(p_alas, '')::INTEGER, NULLIF(p_delas1, '')::INTEGER, NULLIF(p_alas1, '')::INTEGER, p_frec_lunes, p_frec_martes, p_frec_miercoles, p_frec_jueves, p_frec_viernes, p_frec_sabado, p_frec_domingo, p_pol_num, v_pol_fec_ven, p_numlic, p_zona, NULLIF(p_subzona, '')::SMALLINT, p_estatus, NULLIF(p_clave, '')::SMALLINT
    );
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_ta_15_publicos_update_pol_fec_ven
-- Tipo: CRUD
-- Descripción: Actualiza el campo pol_fec_ven en ta_15_publicos para un registro específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ta_15_publicos_update_pol_fec_ven(
    p_sector VARCHAR,
    p_categ VARCHAR,
    p_numero VARCHAR,
    p_fec_venci VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    v_fec_venci DATE;
BEGIN
    IF p_fec_venci IS NULL OR p_fec_venci = '00/00/00' THEN
        v_fec_venci := NULL;
    ELSE
        v_fec_venci := to_date(p_fec_venci, 'DD/MM/YY');
    END IF;
    UPDATE ta_15_publicos
    SET pol_fec_ven = v_fec_venci
    WHERE cve_sector = p_sector AND cve_categ = p_categ AND cve_numero = p_numero;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

