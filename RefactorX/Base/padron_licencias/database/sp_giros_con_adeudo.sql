-- ============================================================================
-- STORED PROCEDURE: sp_giros_dcon_adeudo
-- Descripción: Consulta de giros comerciales con adeudos fiscales pendientes
-- Módulo: GirosDconAdeudofrm (Padrón de Licencias)
-- Parámetros:
--   - p_year: Año de filtrado (opcional)
--   - p_giro: Nombre del giro para búsqueda parcial (opcional)
--   - p_min_debt: Monto mínimo de adeudo (opcional)
--   - p_page: Número de página (paginación)
--   - p_limit: Registros por página
-- Retorna: Lista de giros con estadísticas de adeudos
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

    -- Calcular total de registros (antes de paginar)
    SELECT COUNT(DISTINCT g.id_giro)
    INTO v_total_records
    FROM comun.licencias l
    INNER JOIN comun.c_giros g ON l.id_giro = g.id_giro
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM l.fecha_otorgamiento) = p_year)
      AND (p_giro IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_giro) || '%')
      AND EXISTS (
          SELECT 1
          FROM comun.adeudos a
          WHERE a.cuentas = l.cvecuenta
            AND a.total > 0
            AND (p_min_debt IS NULL OR a.total >= p_min_debt)
      );

    -- Consulta principal con estadísticas por giro
    RETURN QUERY
    WITH giro_stats AS (
        SELECT
            g.id_giro,
            g.descripcion,
            COUNT(DISTINCT l.licencia) as total_lic,
            COUNT(DISTINCT CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM comun.adeudos a
                    WHERE a.cuentas = l.cvecuenta
                      AND a.total > 0
                      AND (p_min_debt IS NULL OR a.total >= p_min_debt)
                ) THEN l.licencia
            END) as lic_adeudo,
            COALESCE(SUM(CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM comun.adeudos a
                    WHERE a.cuentas = l.cvecuenta
                      AND a.total > 0
                ) THEN (
                    SELECT SUM(a2.total)
                    FROM comun.adeudos a2
                    WHERE a2.cuentas = l.cvecuenta
                      AND a2.total > 0
                )
            END), 0) as monto_total
        FROM comun.licencias l
        INNER JOIN comun.c_giros g ON l.id_giro = g.id_giro
        WHERE (p_year IS NULL OR EXTRACT(YEAR FROM l.fecha_otorgamiento) = p_year)
          AND (p_giro IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_giro) || '%')
        GROUP BY g.id_giro, g.descripcion
        HAVING COUNT(DISTINCT CASE
            WHEN EXISTS (
                SELECT 1
                FROM comun.adeudos a
                WHERE a.cuentas = l.cvecuenta
                  AND a.total > 0
                  AND (p_min_debt IS NULL OR a.total >= p_min_debt)
            ) THEN l.licencia
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
-- STORED PROCEDURE: sp_report_giros_dcon_adeudo
-- Descripción: Reporte completo de giros con adeudos para exportación a Excel
-- Módulo: GirosDconAdeudofrm (Padrón de Licencias)
-- Parámetros: Mismos filtros que la consulta principal (sin paginación)
-- Retorna: Lista completa de giros con adeudos
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
    -- Consulta completa sin paginación para reporte
    RETURN QUERY
    WITH giro_stats AS (
        SELECT
            g.id_giro,
            g.descripcion,
            COUNT(DISTINCT l.licencia) as total_lic,
            COUNT(DISTINCT CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM comun.adeudos a
                    WHERE a.cuentas = l.cvecuenta
                      AND a.total > 0
                      AND (p_min_debt IS NULL OR a.total >= p_min_debt)
                ) THEN l.licencia
            END) as lic_adeudo,
            COALESCE(SUM(CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM comun.adeudos a
                    WHERE a.cuentas = l.cvecuenta
                      AND a.total > 0
                ) THEN (
                    SELECT SUM(a2.total)
                    FROM comun.adeudos a2
                    WHERE a2.cuentas = l.cvecuenta
                      AND a2.total > 0
                )
            END), 0) as monto_total
        FROM comun.licencias l
        INNER JOIN comun.c_giros g ON l.id_giro = g.id_giro
        WHERE (p_year IS NULL OR EXTRACT(YEAR FROM l.fecha_otorgamiento) = p_year)
          AND (p_giro IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_giro) || '%')
        GROUP BY g.id_giro, g.descripcion
        HAVING COUNT(DISTINCT CASE
            WHEN EXISTS (
                SELECT 1
                FROM comun.adeudos a
                WHERE a.cuentas = l.cvecuenta
                  AND a.total > 0
                  AND (p_min_debt IS NULL OR a.total >= p_min_debt)
            ) THEN l.licencia
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
-- COMENTARIOS Y PERMISOS
-- ============================================================================

COMMENT ON FUNCTION public.sp_giros_dcon_adeudo IS
'Consulta giros comerciales con adeudos fiscales pendientes con paginación';

COMMENT ON FUNCTION public.sp_report_giros_dcon_adeudo IS
'Reporte completo de giros con adeudos para exportación (sin paginación)';

-- Otorgar permisos de ejecución
GRANT EXECUTE ON FUNCTION public.sp_giros_dcon_adeudo TO public;
GRANT EXECUTE ON FUNCTION public.sp_report_giros_dcon_adeudo TO public;
