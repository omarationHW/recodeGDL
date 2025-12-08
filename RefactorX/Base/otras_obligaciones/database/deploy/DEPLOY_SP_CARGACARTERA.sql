-- =====================================================
-- SPs para CargaCartera - otras_obligaciones
-- Fecha: 2025-11-26
-- =====================================================

-- 1. SP para obtener tablas (sin parámetros)
DROP FUNCTION IF EXISTS public.sp_cargacartera_get_tablas();
CREATE OR REPLACE FUNCTION public.sp_cargacartera_get_tablas()
RETURNS TABLE(
    id_34_tab INTEGER,
    cve_tab CHARACTER(1),
    nombre CHARACTER VARYING,
    cajero CHARACTER(1),
    auto_tab INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_34_tab,
        t.cve_tab,
        t.nombre,
        t.cajero,
        t.auto_tab
    FROM t34_tablas t
    WHERE t.cajero = 'N'  -- Solo tablas que no son de cajero
      AND t.cve_tab NOT IN ('A', 'C', 'D', 'E', 'F', 'G')  -- Excluir tablas auxiliares
    ORDER BY t.cve_tab;
END;
$$;

-- 2. SP para obtener ejercicios (desde t34_unidades)
DROP FUNCTION IF EXISTS public.sp_cargacartera_get_ejercicios(CHARACTER VARYING);
CREATE OR REPLACE FUNCTION public.sp_cargacartera_get_ejercicios(
    par_cve_tab CHARACTER VARYING DEFAULT NULL
)
RETURNS TABLE(
    ejercicio INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF par_cve_tab IS NOT NULL AND par_cve_tab != '' THEN
        RETURN QUERY
        SELECT DISTINCT u.ejercicio
        FROM t34_unidades u
        WHERE u.cve_tab = par_cve_tab
        ORDER BY u.ejercicio DESC;
    ELSE
        RETURN QUERY
        SELECT DISTINCT u.ejercicio
        FROM t34_unidades u
        ORDER BY u.ejercicio DESC;
    END IF;
END;
$$;

-- 3. SP para obtener unidades (desde t34_unidades)
DROP FUNCTION IF EXISTS public.sp_cargacartera_get_unidades(CHARACTER VARYING, INTEGER);
CREATE OR REPLACE FUNCTION public.sp_cargacartera_get_unidades(
    p_cve_tab CHARACTER VARYING,
    p_ejercicio INTEGER
)
RETURNS TABLE(
    id_34_unidad INTEGER,
    ejercicio INTEGER,
    cve_unidad CHARACTER(1),
    cve_operatividad CHARACTER(1),
    descripcion CHARACTER VARYING,
    costo NUMERIC,
    cve_tab CHARACTER(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id_34_unidad,
        u.ejercicio,
        u.cve_unidad,
        u.cve_operatividad,
        u.descripcion,
        u.costo,
        u.cve_tab
    FROM t34_unidades u
    WHERE u.cve_tab = p_cve_tab
      AND u.ejercicio = p_ejercicio
    ORDER BY u.cve_unidad, u.cve_operatividad;
END;
$$;

-- Verificación
DO $$
BEGIN
    RAISE NOTICE 'SPs de CargaCartera creados exitosamente';
END $$;
