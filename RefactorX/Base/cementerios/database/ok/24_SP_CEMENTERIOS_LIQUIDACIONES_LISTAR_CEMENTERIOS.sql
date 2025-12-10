-- =============================================
-- MÓDULO: Liquidaciones de Cementerios - Listar Cementerios
-- ARCHIVO: 24_SP_CEMENTERIOS_LIQUIDACIONES_LISTAR_CEMENTERIOS.sql
-- DESCRIPCIÓN: SP adicional para listar cementerios
-- FECHA: 2025-11-25
-- NOTA: Complementa a 11_SP_CEMENTERIOS_LIQUIDACIONES (sp_liquidaciones_calcular)
-- ESQUEMAS SEGÚN postgreok.csv:
--   - tc_13_cementerios → cementerio.public
-- =============================================

-- =============================================
-- SP: sp_get_cementerios_list
-- Lista todos los cementerios
-- Origen: Liquidaciones.vue línea 313-324
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_get_cementerios_list()
RETURNS TABLE(
    cementerio bpchar(1),
    nombre VARCHAR(60),
    domicilio VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM public.tc_13_cementerios c
    ORDER BY c.cementerio;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- COMENTARIOS Y NOTAS:
-- 1. Complementa a 11_SP_CEMENTERIOS_LIQUIDACIONES (sp_liquidaciones_calcular ya existe)
-- 2. Usa esquema correcto según postgreok.csv
-- 3. SP de consulta (solo lectura)
-- =============================================
