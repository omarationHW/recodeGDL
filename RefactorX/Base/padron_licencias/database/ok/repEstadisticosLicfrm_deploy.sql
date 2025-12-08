-- ============================================
-- DEPLOY CONSOLIDADO: repEstadisticosLicfrm
-- Componente 85/95 - BATCH 17
-- Generado: 2025-11-20
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_rep_estadisticos_lic_rango
CREATE OR REPLACE FUNCTION public.sp_rep_estadisticos_lic_rango(p_fecha1 DATE, p_fecha2 DATE)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_giro,
        c.descripcion::TEXT,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END)::INTEGER AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END)::INTEGER AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END)::INTEGER AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END)::INTEGER AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END)::INTEGER AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END)::INTEGER AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END)::INTEGER AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END)::INTEGER AS otros,
        COUNT(*)::INTEGER AS total
    FROM licencias l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
      AND l.fecha_otorgamiento >= p_fecha1
      AND l.fecha_otorgamiento <= p_fecha2
    GROUP BY l.id_giro, c.descripcion
    ORDER BY l.id_giro;
END;
$$ LANGUAGE plpgsql;

-- SP 2/5: sp_rep_estadisticos_lic_giro_zona
CREATE OR REPLACE FUNCTION public.sp_rep_estadisticos_lic_giro_zona()
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_giro,
        c.descripcion::TEXT,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END)::INTEGER AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END)::INTEGER AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END)::INTEGER AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END)::INTEGER AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END)::INTEGER AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END)::INTEGER AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END)::INTEGER AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END)::INTEGER AS otros,
        COUNT(*)::INTEGER AS total
    FROM licencias l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
    GROUP BY l.id_giro, c.descripcion
    ORDER BY l.id_giro;
END;
$$ LANGUAGE plpgsql;

-- SP 3/5: sp_rep_estadisticos_giros_reglamentados_zona
CREATE OR REPLACE FUNCTION public.sp_rep_estadisticos_giros_reglamentados_zona(p_clasificacion TEXT DEFAULT NULL)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    clasificacion TEXT,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_giro,
        c.descripcion::TEXT,
        c.clasificacion::TEXT,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END)::INTEGER AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END)::INTEGER AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END)::INTEGER AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END)::INTEGER AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END)::INTEGER AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END)::INTEGER AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END)::INTEGER AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END)::INTEGER AS otros,
        COUNT(*)::INTEGER AS total
    FROM licencias l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
      AND (
        (p_clasificacion IS NULL AND (c.clasificacion = 'C' OR c.clasificacion = 'D')) OR
        (p_clasificacion IS NOT NULL AND c.clasificacion = p_clasificacion)
      )
    GROUP BY l.id_giro, c.descripcion, c.clasificacion
    ORDER BY c.clasificacion, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP 4/5: sp_rep_estadisticos_lic_reglamentadas_rango
CREATE OR REPLACE FUNCTION public.sp_rep_estadisticos_lic_reglamentadas_rango(
    p_fecha1 DATE,
    p_fecha2 DATE,
    p_clasificacion TEXT DEFAULT NULL
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    clasificacion TEXT,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_giro,
        c.descripcion::TEXT,
        c.clasificacion::TEXT,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END)::INTEGER AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END)::INTEGER AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END)::INTEGER AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END)::INTEGER AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END)::INTEGER AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END)::INTEGER AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END)::INTEGER AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END)::INTEGER AS otros,
        COUNT(*)::INTEGER AS total
    FROM licencias l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
      AND l.fecha_otorgamiento >= p_fecha1
      AND l.fecha_otorgamiento <= p_fecha2
      AND (
        (p_clasificacion IS NULL AND (c.clasificacion = 'C' OR c.clasificacion = 'D')) OR
        (p_clasificacion IS NOT NULL AND c.clasificacion = p_clasificacion)
      )
    GROUP BY l.id_giro, c.descripcion, c.clasificacion
    ORDER BY c.clasificacion, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP 5/5: sp_rep_estadisticos_pagos_lic_rango
CREATE OR REPLACE FUNCTION public.sp_rep_estadisticos_pagos_lic_rango(p_fecha1 DATE, p_fecha2 DATE)
RETURNS TABLE(
    recaud INTEGER,
    cuantos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.recaud,
        COUNT(*)::INTEGER AS cuantos
    FROM pagos p
    JOIN licencias l ON l.id_licencia = p.cvecuenta
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE p.cveconcepto = 8
      AND p.cvecanc IS NULL
      AND c.tipo = 'L'
      AND p.fecha BETWEEN p_fecha1 AND p_fecha2
    GROUP BY p.recaud
    ORDER BY p.recaud;
END;
$$ LANGUAGE plpgsql;
