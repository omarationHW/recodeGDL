-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: HASTAFRM (EXACTO del archivo original)
-- Archivo: 58_SP_RECAUDADORA_HASTAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_validate_hasta_form
-- Tipo: CRUD
-- Descripción: Valida los datos del formulario 'Pagar hasta' (bimestre y año). Devuelve un registro con los campos validados y un mensaje.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_validate_hasta_form(p_bimestre integer, p_anio integer)
RETURNS TABLE(
    is_valid boolean,
    bimestre integer,
    anio integer,
    message text
) AS $$
DECLARE
    current_year integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    IF p_bimestre IS NULL OR p_bimestre < 1 OR p_bimestre > 6 THEN
        RETURN QUERY SELECT false, p_bimestre, p_anio, 'Bimestre inválido!';
        RETURN;
    END IF;
    IF p_anio IS NULL OR p_anio < 1970 OR p_anio > current_year THEN
        RETURN QUERY SELECT false, p_bimestre, p_anio, 'Año inválido!';
        RETURN;
    END IF;
    RETURN QUERY SELECT true, p_bimestre, p_anio, 'Datos validados correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

