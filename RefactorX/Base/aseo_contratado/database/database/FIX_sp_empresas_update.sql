-- ============================================
-- FIX URGENTE: sp_empresas_update
-- Problema: Ambiguous column reference
-- Solucion: Usar alias de tabla en WHERE
-- Fecha: 2025-12-07
-- ============================================

-- Eliminar la funcion existente (todas las versiones)
DROP FUNCTION IF EXISTS public.sp_empresas_update(INTEGER, INTEGER, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS sp_empresas_update(INTEGER, INTEGER, VARCHAR, VARCHAR);

-- Crear la funcion corregida
CREATE OR REPLACE FUNCTION sp_empresas_update(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR,
    p_representante VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- IMPORTANTE: Usar alias 'e' para evitar ambiguedad
    UPDATE ta_16_empresas e
    SET descripcion = p_descripcion,
        representante = p_representante
    WHERE e.num_empresa = p_num_empresa
      AND e.ctrol_emp = p_ctrol_emp;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Empresa actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No se encontro la empresa'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Permisos
GRANT EXECUTE ON FUNCTION sp_empresas_update(INTEGER, INTEGER, VARCHAR, VARCHAR) TO PUBLIC;

-- Verificar que se creo correctamente
SELECT 'SP sp_empresas_update creado correctamente' AS resultado;
