-- =============================================
-- ABC_Recargos - Stored Procedures
-- Base de datos: aseo_contratado
-- Tabla: ta_16_recargos
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- =============================================

-- NOTA: La tabla ta_16_recargos usa TIMESTAMP, no DATE

-- =============================================
-- SP 1/4: sp_recargos_list
-- Descripción: Lista todos los recargos, opcionalmente filtrado por año
-- Parámetros:
--   p_year: Año a filtrar (opcional, NULL = todos)
-- =============================================
DROP FUNCTION IF EXISTS public.sp_recargos_list(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_recargos_list(p_year INTEGER DEFAULT NULL)
RETURNS TABLE (
    aso_mes_recargo TIMESTAMP,
    porc_recargo NUMERIC,
    porc_multa NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.aso_mes_recargo, r.porc_recargo, r.porc_multa
    FROM ta_16_recargos r
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM r.aso_mes_recargo) = p_year)
    ORDER BY r.aso_mes_recargo DESC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_recargos_list(INTEGER) TO PUBLIC;

-- =============================================
-- SP 2/4: sp_recargos_create
-- Descripción: Crea un nuevo registro de recargo
-- Parámetros:
--   p_aso_mes_recargo: Fecha del periodo (primer día del mes)
--   p_porc_recargo: Porcentaje de recargo
--   p_porc_multa: Porcentaje de multa
-- Retorna: success (boolean), message (text)
-- =============================================
DROP FUNCTION IF EXISTS public.sp_recargos_create(TIMESTAMP, NUMERIC, NUMERIC);

CREATE OR REPLACE FUNCTION public.sp_recargos_create(
    p_aso_mes_recargo TIMESTAMP,
    p_porc_recargo NUMERIC,
    p_porc_multa NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si ya existe
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_recargos r
    WHERE r.aso_mes_recargo = p_aso_mes_recargo;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un recargo para ese periodo'::TEXT;
        RETURN;
    END IF;

    -- Insertar
    INSERT INTO ta_16_recargos (aso_mes_recargo, porc_recargo, porc_multa)
    VALUES (p_aso_mes_recargo, p_porc_recargo, p_porc_multa);

    RETURN QUERY SELECT true, 'Recargo creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_recargos_create(TIMESTAMP, NUMERIC, NUMERIC) TO PUBLIC;

-- =============================================
-- SP 3/4: sp_recargos_update
-- Descripción: Actualiza un registro de recargo existente
-- Parámetros:
--   p_aso_mes_recargo: Fecha del periodo (clave primaria)
--   p_porc_recargo: Nuevo porcentaje de recargo
--   p_porc_multa: Nuevo porcentaje de multa
-- Retorna: success (boolean), message (text)
-- =============================================
DROP FUNCTION IF EXISTS public.sp_recargos_update(TIMESTAMP, NUMERIC, NUMERIC);

CREATE OR REPLACE FUNCTION public.sp_recargos_update(
    p_aso_mes_recargo TIMESTAMP,
    p_porc_recargo NUMERIC,
    p_porc_multa NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE ta_16_recargos r
    SET porc_recargo = p_porc_recargo,
        porc_multa = p_porc_multa
    WHERE r.aso_mes_recargo = p_aso_mes_recargo;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recargo actualizado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_recargos_update(TIMESTAMP, NUMERIC, NUMERIC) TO PUBLIC;

-- =============================================
-- SP 4/4: sp_recargos_delete
-- Descripción: Elimina un registro de recargo
-- Parámetros:
--   p_aso_mes_recargo: Fecha del periodo a eliminar
-- Retorna: success (boolean), message (text)
-- =============================================
DROP FUNCTION IF EXISTS public.sp_recargos_delete(TIMESTAMP);

CREATE OR REPLACE FUNCTION public.sp_recargos_delete(
    p_aso_mes_recargo TIMESTAMP
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    DELETE FROM ta_16_recargos r
    WHERE r.aso_mes_recargo = p_aso_mes_recargo;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recargo eliminado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_recargos_delete(TIMESTAMP) TO PUBLIC;
