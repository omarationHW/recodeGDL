-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Formulario: Hastafrm
-- Fecha Implementación: 2025-11-20
-- Total SPs: 1
-- ============================================

-- ============================================
-- SP 1/1: sp_validate_hasta_form
-- Tipo: VALIDACIÓN
-- Descripción: Valida los datos del formulario 'Pagar hasta' (bimestre y año)
-- Parámetros:
--   p_bimestre: INTEGER - Número de bimestre (1-6)
--   p_anio: INTEGER - Año (1970 hasta año actual)
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_validate_hasta_form(
    p_bimestre INTEGER,
    p_anio INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_current_year INTEGER;
    v_min_year INTEGER := 1970;
    v_max_bimestre INTEGER := 6;
    v_min_bimestre INTEGER := 1;
BEGIN
    -- Obtener año actual
    v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);

    -- Validar que los parámetros no sean nulos
    IF p_bimestre IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El bimestre no puede ser nulo.'::TEXT;
        RETURN;
    END IF;

    IF p_anio IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El año no puede ser nulo.'::TEXT;
        RETURN;
    END IF;

    -- Validar rango de bimestre (1-6)
    IF p_bimestre < v_min_bimestre OR p_bimestre > v_max_bimestre THEN
        RETURN QUERY SELECT FALSE,
            ('Bimestre inválido: debe ser entre ' || v_min_bimestre || ' y ' || v_max_bimestre || '.')::TEXT;
        RETURN;
    END IF;

    -- Validar rango de año (1970 hasta año actual)
    IF p_anio < v_min_year OR p_anio > v_current_year THEN
        RETURN QUERY SELECT FALSE,
            ('Año inválido: debe ser entre ' || v_min_year || ' y ' || v_current_year || '.')::TEXT;
        RETURN;
    END IF;

    -- Todas las validaciones pasaron
    RETURN QUERY SELECT TRUE, 'Validación exitosa.'::TEXT;

END;
$$ LANGUAGE plpgsql;

-- Comentario descriptivo
COMMENT ON FUNCTION public.sp_validate_hasta_form(INTEGER, INTEGER) IS
'Valida los datos del formulario Pagar Hasta (bimestre y año). Verifica que el bimestre esté entre 1 y 6, y que el año esté entre 1970 y el año actual.';

-- ============================================
-- FIN IMPLEMENTACIÓN HASTAFRM
-- ============================================
