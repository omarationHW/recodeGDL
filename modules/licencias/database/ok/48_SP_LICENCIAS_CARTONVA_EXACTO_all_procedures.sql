-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARTONVA (EXACTO del archivo original)
-- Archivo: 48_SP_LICENCIAS_CARTONVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_get_cartografia_predial
-- Tipo: CRUD
-- Descripción: Obtiene la información de la cuenta catastral y la URL del visor cartográfico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cartografia_predial(p_cvecuenta INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION,
    visor_url TEXT
) AS $$
DECLARE
    v_cvecatnva VARCHAR(11);
    v_url TEXT;
BEGIN
    SELECT * INTO STRICT cvecuenta, cvemunicipio, recaud, urbrus, cuenta, digver, zonaanter, manzanter, loteanter, cvecatnva, subpredio, crec, cur, ccta, cip, vigente, cvelocalidad, coordenada_x, coordenada_y
    FROM convcta WHERE cvecuenta = p_cvecuenta;
    v_cvecatnva := cvecatnva;
    v_url := 'http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=' || v_cvecatnva;
    visor_url := v_url;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARTONVA (EXACTO del archivo original)
-- Archivo: 48_SP_LICENCIAS_CARTONVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

