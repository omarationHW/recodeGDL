-- =============================================
-- Aseo Contratado - EjerciciosGestion Module
-- Stored Procedures for Fiscal Year Management
-- Database: aseo_contratado
-- Schema: public
-- =============================================

-- =============================================
-- Function: ejercicios_sp_listar
-- Description: List all fiscal years
-- =============================================
CREATE OR REPLACE FUNCTION public.ejercicios_sp_listar()
RETURNS TABLE (
    ejercicio SMALLINT,
    descripcion VARCHAR,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo CHAR(1),
    cerrado CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.ejercicio,
        CAST('Ejercicio ' || e.ejercicio AS VARCHAR) as descripcion,
        (e.ejercicio || '-01-01')::DATE as fecha_inicio,
        (e.ejercicio || '-12-31')::DATE as fecha_fin,
        CASE WHEN e.ejercicio = EXTRACT(YEAR FROM CURRENT_DATE) THEN 'S' ELSE 'N' END::CHAR(1) as activo,
        CASE WHEN e.ejercicio < EXTRACT(YEAR FROM CURRENT_DATE) THEN 'S' ELSE 'N' END::CHAR(1) as cerrado
    FROM (
        SELECT DISTINCT EXTRACT(YEAR FROM c.fecha_hora_alta)::SMALLINT as ejercicio
        FROM ta_16_contratos c
        WHERE c.fecha_hora_alta IS NOT NULL
        UNION
        SELECT EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT
        UNION
        SELECT (EXTRACT(YEAR FROM CURRENT_DATE) - 1)::SMALLINT
        UNION
        SELECT (EXTRACT(YEAR FROM CURRENT_DATE) + 1)::SMALLINT
    ) e
    ORDER BY e.ejercicio DESC;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: ejercicios_sp_get_actual
-- Description: Get current fiscal year
-- =============================================
CREATE OR REPLACE FUNCTION public.ejercicios_sp_get_actual()
RETURNS TABLE (
    ejercicio SMALLINT,
    mes_actual SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT as ejercicio,
        EXTRACT(MONTH FROM CURRENT_DATE)::SMALLINT as mes_actual,
        CAST('Ejercicio ' || EXTRACT(YEAR FROM CURRENT_DATE) AS VARCHAR) as descripcion;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: ejercicios_sp_estadisticas
-- Description: Get statistics for a fiscal year
-- =============================================
CREATE OR REPLACE FUNCTION public.ejercicios_sp_estadisticas(
    p_ejercicio SMALLINT
)
RETURNS TABLE (
    ejercicio SMALLINT,
    total_contratos INTEGER,
    contratos_vigentes INTEGER,
    contratos_nuevos INTEGER,
    contratos_cancelados INTEGER,
    contratos_suspendidos INTEGER,
    total_empresas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p_ejercicio as ejercicio,
        COUNT(*)::INTEGER as total_contratos,
        COUNT(CASE WHEN c.status_vigencia = 'V' THEN 1 END)::INTEGER as contratos_vigentes,
        COUNT(CASE WHEN c.status_vigencia = 'N' THEN 1 END)::INTEGER as contratos_nuevos,
        COUNT(CASE WHEN c.status_vigencia = 'C' THEN 1 END)::INTEGER as contratos_cancelados,
        COUNT(CASE WHEN c.status_vigencia = 'S' THEN 1 END)::INTEGER as contratos_suspendidos,
        COUNT(DISTINCT c.num_empresa)::INTEGER as total_empresas
    FROM ta_16_contratos c
    WHERE EXTRACT(YEAR FROM c.fecha_hora_alta) = p_ejercicio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.ejercicios_sp_listar() IS 'List all fiscal years - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.ejercicios_sp_get_actual() IS 'Get current fiscal year - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.ejercicios_sp_estadisticas(SMALLINT) IS 'Get fiscal year statistics - RefactorX Aseo Contratado';
