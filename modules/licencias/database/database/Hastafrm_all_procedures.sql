-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Hastafrm
-- Generado: 2025-08-27 18:25:24
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_validate_hasta_form
-- Tipo: CRUD
-- Descripción: Valida los datos del formulario 'Pagar hasta' (bimestre y año). Retorna mensaje de éxito o error.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_validate_hasta_form(p_bimestre integer, p_anio integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    current_year integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    IF p_bimestre IS NULL OR p_bimestre < 1 OR p_bimestre > 6 THEN
        RETURN QUERY SELECT false, 'Bimestre inválido: debe ser entre 1 y 6.';
        RETURN;
    END IF;
    IF p_anio IS NULL OR p_anio < 1970 OR p_anio > current_year THEN
        RETURN QUERY SELECT false, 'Año inválido: debe ser entre 1970 y ' || current_year || '.';
        RETURN;
    END IF;
    RETURN QUERY SELECT true, 'Validación exitosa.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

