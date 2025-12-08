-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Recaudadoras
-- Base de datos: aseo_contratado
-- Tabla: ta_16_recaudadoras
-- Actualizado: 2025-12-07
-- Total SPs: 5
-- ============================================

-- ============================================
-- SP 1/5: sp_list_recaudadoras
-- Descripción: Lista todas las recaudadoras ordenadas por número
-- Parámetros: ninguno
-- ============================================
DROP FUNCTION IF EXISTS public.sp_list_recaudadoras();

CREATE OR REPLACE FUNCTION public.sp_list_recaudadoras()
RETURNS TABLE (
    num_rec INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.num_rec, r.descripcion
    FROM ta_16_recaudadoras r
    ORDER BY r.num_rec;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_list_recaudadoras() TO PUBLIC;

-- ============================================
-- SP 2/5: sp_get_next_num_recaudadora
-- Descripción: Obtiene el siguiente número disponible para recaudadora
-- Parámetros: ninguno
-- ============================================
DROP FUNCTION IF EXISTS public.sp_get_next_num_recaudadora();

CREATE OR REPLACE FUNCTION public.sp_get_next_num_recaudadora()
RETURNS TABLE (next_num INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(MAX(r.num_rec), 0) + 1
    FROM ta_16_recaudadoras r;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_get_next_num_recaudadora() TO PUBLIC;

-- ============================================
-- SP 3/5: sp_insert_recaudadora
-- Descripción: Inserta una nueva recaudadora
-- Parámetros:
--   p_num_rec: Número de recaudadora (clave primaria)
--   p_descripcion: Descripción/nombre de la recaudadora
-- Retorna: success (boolean), message (text)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_insert_recaudadora(INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_insert_recaudadora(
    p_num_rec INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si ya existe
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_recaudadoras r
    WHERE r.num_rec = p_num_rec;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe una recaudadora con ese número'::TEXT;
        RETURN;
    END IF;

    -- Insertar
    INSERT INTO ta_16_recaudadoras (num_rec, descripcion)
    VALUES (p_num_rec, p_descripcion);

    RETURN QUERY SELECT true, 'Recaudadora creada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_insert_recaudadora(INTEGER, VARCHAR) TO PUBLIC;

-- ============================================
-- SP 4/5: sp_update_recaudadora
-- Descripción: Actualiza la descripción de una recaudadora
-- Parámetros:
--   p_num_rec: Número de recaudadora a actualizar
--   p_descripcion: Nueva descripción
-- Retorna: success (boolean), message (text)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_update_recaudadora(INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_update_recaudadora(
    p_num_rec INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE ta_16_recaudadoras r
    SET descripcion = p_descripcion
    WHERE r.num_rec = p_num_rec;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recaudadora actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la recaudadora'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_update_recaudadora(INTEGER, VARCHAR) TO PUBLIC;

-- ============================================
-- SP 5/5: sp_delete_recaudadora
-- Descripción: Elimina una recaudadora si no tiene contratos asociados
-- Parámetros:
--   p_num_rec: Número de recaudadora a eliminar
-- Retorna: success (boolean), message (text)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_delete_recaudadora(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_delete_recaudadora(
    p_num_rec INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    -- Verificar si tiene contratos asociados
    SELECT COUNT(*) INTO v_contratos
    FROM ta_16_contratos c
    WHERE c.num_rec = p_num_rec;

    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, ('No se puede eliminar: tiene ' || v_contratos || ' contrato(s) asociado(s)')::TEXT;
        RETURN;
    END IF;

    -- Eliminar
    DELETE FROM ta_16_recaudadoras r
    WHERE r.num_rec = p_num_rec;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recaudadora eliminada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la recaudadora'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_delete_recaudadora(INTEGER) TO PUBLIC;
