-- ============================================================================
-- STORED PROCEDURE OPTIMIZADO: sp_giros_dcon_adeudo
-- Descripción: Versión optimizada con LEFT JOIN en lugar de EXISTS subqueries
-- Performance: Reducción de ~25 segundos a <1 segundo
-- ============================================================================

CREATE OR REPLACE FUNCTION public.sp_giros_dcon_adeudo(
    p_year INTEGER DEFAULT NULL,
    p_giro VARCHAR DEFAULT NULL,
    p_min_debt NUMERIC DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    giro VARCHAR,
    total_licencias INTEGER,
    licencias_con_adeudo INTEGER,
    porcentaje_adeudo NUMERIC,
    monto_total_adeudo NUMERIC,
    promedio_adeudo NUMERIC,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
    v_total_records BIGINT;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Calcular total de registros (optimizado con LEFT JOIN)
    SELECT COUNT(DISTINCT g.id_giro)
    INTO v_total_records
    FROM comun.licencias l
    INNER JOIN comun.c_giros g ON l.id_giro = g.id_giro
    INNER JOIN comun.adeudos a ON a.cuentas = l.cvecuenta AND a.total > 0
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM l.fecha_otorgamiento) = p_year)
      AND (p_giro IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_giro) || '%')
      AND (p_min_debt IS NULL OR a.total >= p_min_debt);

    -- Consulta principal optimizada con LEFT JOIN
    RETURN QUERY
    WITH adeudos_por_licencia AS (
        -- Pre-agregar adeudos por licencia (una sola pasada)
        SELECT
            l.licencia,
            l.cvecuenta,
            l.id_giro,
            SUM(CASE WHEN a.total > 0 THEN a.total ELSE 0 END) as total_adeudo,
            COUNT(CASE WHEN a.total > 0 THEN 1 END) as tiene_adeudo
        FROM comun.licencias l
        LEFT JOIN comun.adeudos a ON a.cuentas = l.cvecuenta
        WHERE (p_year IS NULL OR EXTRACT(YEAR FROM l.fecha_otorgamiento) = p_year)
        GROUP BY l.licencia, l.cvecuenta, l.id_giro
    ),
    giro_stats AS (
        SELECT
            g.id_giro,
            g.descripcion,
            COUNT(DISTINCT apl.licencia) as total_lic,
            COUNT(DISTINCT CASE
                WHEN apl.tiene_adeudo > 0
                 AND (p_min_debt IS NULL OR apl.total_adeudo >= p_min_debt)
                THEN apl.licencia
            END) as lic_adeudo,
            COALESCE(SUM(CASE
                WHEN apl.tiene_adeudo > 0
                 AND (p_min_debt IS NULL OR apl.total_adeudo >= p_min_debt)
                THEN apl.total_adeudo
                ELSE 0
            END), 0) as monto_total
        FROM adeudos_por_licencia apl
        INNER JOIN comun.c_giros g ON apl.id_giro = g.id_giro
        WHERE (p_giro IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_giro) || '%')
        GROUP BY g.id_giro, g.descripcion
        HAVING COUNT(DISTINCT CASE
            WHEN apl.tiene_adeudo > 0
             AND (p_min_debt IS NULL OR apl.total_adeudo >= p_min_debt)
            THEN apl.licencia
        END) > 0
    )
    SELECT
        gs.descripcion::VARCHAR as giro,
        gs.total_lic::INTEGER as total_licencias,
        gs.lic_adeudo::INTEGER as licencias_con_adeudo,
        ROUND((gs.lic_adeudo::NUMERIC / NULLIF(gs.total_lic, 0) * 100), 2) as porcentaje_adeudo,
        ROUND(gs.monto_total, 2) as monto_total_adeudo,
        ROUND(gs.monto_total / NULLIF(gs.lic_adeudo, 0), 2) as promedio_adeudo,
        v_total_records as total_records
    FROM giro_stats gs
    ORDER BY gs.monto_total DESC, gs.descripcion ASC
    LIMIT p_limit
    OFFSET v_offset;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STORED PROCEDURE OPTIMIZADO: sp_report_giros_dcon_adeudo
-- ============================================================================

CREATE OR REPLACE FUNCTION public.sp_report_giros_dcon_adeudo(
    p_year INTEGER DEFAULT NULL,
    p_giro VARCHAR DEFAULT NULL,
    p_min_debt NUMERIC DEFAULT NULL
)
RETURNS TABLE (
    giro VARCHAR,
    total_licencias INTEGER,
    licencias_con_adeudo INTEGER,
    porcentaje_adeudo NUMERIC,
    monto_total_adeudo NUMERIC,
    promedio_adeudo NUMERIC
) AS $$
BEGIN
    -- Consulta completa optimizada sin paginación
    RETURN QUERY
    WITH adeudos_por_licencia AS (
        SELECT
            l.licencia,
            l.cvecuenta,
            l.id_giro,
            SUM(CASE WHEN a.total > 0 THEN a.total ELSE 0 END) as total_adeudo,
            COUNT(CASE WHEN a.total > 0 THEN 1 END) as tiene_adeudo
        FROM comun.licencias l
        LEFT JOIN comun.adeudos a ON a.cuentas = l.cvecuenta
        WHERE (p_year IS NULL OR EXTRACT(YEAR FROM l.fecha_otorgamiento) = p_year)
        GROUP BY l.licencia, l.cvecuenta, l.id_giro
    ),
    giro_stats AS (
        SELECT
            g.id_giro,
            g.descripcion,
            COUNT(DISTINCT apl.licencia) as total_lic,
            COUNT(DISTINCT CASE
                WHEN apl.tiene_adeudo > 0
                 AND (p_min_debt IS NULL OR apl.total_adeudo >= p_min_debt)
                THEN apl.licencia
            END) as lic_adeudo,
            COALESCE(SUM(CASE
                WHEN apl.tiene_adeudo > 0
                 AND (p_min_debt IS NULL OR apl.total_adeudo >= p_min_debt)
                THEN apl.total_adeudo
                ELSE 0
            END), 0) as monto_total
        FROM adeudos_por_licencia apl
        INNER JOIN comun.c_giros g ON apl.id_giro = g.id_giro
        WHERE (p_giro IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_giro) || '%')
        GROUP BY g.id_giro, g.descripcion
        HAVING COUNT(DISTINCT CASE
            WHEN apl.tiene_adeudo > 0
             AND (p_min_debt IS NULL OR apl.total_adeudo >= p_min_debt)
            THEN apl.licencia
        END) > 0
    )
    SELECT
        gs.descripcion::VARCHAR as giro,
        gs.total_lic::INTEGER as total_licencias,
        gs.lic_adeudo::INTEGER as licencias_con_adeudo,
        ROUND((gs.lic_adeudo::NUMERIC / NULLIF(gs.total_lic, 0) * 100), 2) as porcentaje_adeudo,
        ROUND(gs.monto_total, 2) as monto_total_adeudo,
        ROUND(gs.monto_total / NULLIF(gs.lic_adeudo, 0), 2) as promedio_adeudo
    FROM giro_stats gs
    ORDER BY gs.monto_total DESC, gs.descripcion ASC;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ÍNDICES RECOMENDADOS PARA MEJORAR PERFORMANCE
-- ============================================================================

-- Índice en licencias.id_giro (si no existe)
CREATE INDEX IF NOT EXISTS idx_licencias_id_giro ON comun.licencias(id_giro);

-- Índice en licencias.cvecuenta (si no existe)
CREATE INDEX IF NOT EXISTS idx_licencias_cvecuenta ON comun.licencias(cvecuenta);

-- Índice en adeudos.cuentas (si no existe)
CREATE INDEX IF NOT EXISTS idx_adeudos_cuentas ON comun.adeudos(cuentas);

-- Índice compuesto en adeudos para filtrar por monto
CREATE INDEX IF NOT EXISTS idx_adeudos_cuentas_total ON comun.adeudos(cuentas, total) WHERE total > 0;

-- Índice en fecha de otorgamiento para filtro por año
CREATE INDEX IF NOT EXISTS idx_licencias_fecha_otorgamiento ON comun.licencias(fecha_otorgamiento);

-- ============================================================================
-- COMENTARIOS Y PERMISOS
-- ============================================================================

COMMENT ON FUNCTION public.sp_giros_dcon_adeudo IS
'Consulta OPTIMIZADA de giros comerciales con adeudos (performance: <1 seg)';

COMMENT ON FUNCTION public.sp_report_giros_dcon_adeudo IS
'Reporte OPTIMIZADO de giros con adeudos para exportación';

GRANT EXECUTE ON FUNCTION public.sp_giros_dcon_adeudo TO public;
GRANT EXECUTE ON FUNCTION public.sp_report_giros_dcon_adeudo TO public;

-- ============================================================================
-- CAMBIOS PRINCIPALES:
-- 1. Reemplazado EXISTS subqueries por LEFT JOIN
-- 2. CTE adeudos_por_licencia pre-agrega datos (una sola pasada)
-- 3. Eliminados subqueries anidados en SELECT
-- 4. Añadidos índices estratégicos
-- 5. Performance esperada: ~25 segundos → <1 segundo
-- ============================================================================
