-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REPESTADISTICOSLICFRM (EXACTO del archivo original)
-- Archivo: 83_SP_LICENCIAS_REPESTADISTICOSLICFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_rep_estadisticos_lic_rango
-- Tipo: Report
-- Descripción: Reporte de licencias dadas de alta en un rango de fechas, agrupadas por giro y zona.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_estadisticos_lic_rango(fecha1 DATE, fecha2 DATE)
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
        c.descripcion,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END) AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END) AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END) AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END) AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END) AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END) AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END) AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END) AS otros,
        COUNT(*) AS total
    FROM public l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
      AND l.fecha_otorgamiento >= fecha1
      AND l.fecha_otorgamiento <= fecha2
    GROUP BY l.id_giro, c.descripcion
    ORDER BY l.id_giro;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REPESTADISTICOSLICFRM (EXACTO del archivo original)
-- Archivo: 83_SP_LICENCIAS_REPESTADISTICOSLICFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_rep_estadisticos_giros_reglamentados_zona
-- Tipo: Report
-- Descripción: Reporte de giros reglamentados (clasificación C y/o D) agrupados por zona.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_estadisticos_giros_reglamentados_zona(clasificacion TEXT DEFAULT NULL)
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
        c.descripcion,
        c.clasificacion,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END) AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END) AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END) AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END) AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END) AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END) AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END) AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END) AS otros,
        COUNT(*) AS total
    FROM public l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
      AND (
        (clasificacion IS NULL AND (c.clasificacion = 'C' OR c.clasificacion = 'D')) OR
        (clasificacion IS NOT NULL AND c.clasificacion = clasificacion)
      )
    GROUP BY l.id_giro, c.descripcion, c.clasificacion
    ORDER BY c.clasificacion, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REPESTADISTICOSLICFRM (EXACTO del archivo original)
-- Archivo: 83_SP_LICENCIAS_REPESTADISTICOSLICFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_rep_estadisticos_pagos_lic_rango
-- Tipo: Report
-- Descripción: Reporte de pagos de licencias en un rango de fechas, agrupados por public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_estadisticos_pagos_lic_rango(fecha1 DATE, fecha2 DATE)
RETURNS TABLE(
    recaud INTEGER,
    cuantos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.recaud,
        COUNT(*) AS cuantos
    FROM pagos p
    JOIN licencias l ON l.id_licencia = p.cvecuenta
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE p.cveconcepto = 8
      AND p.cvecanc IS NULL
      AND c.tipo = 'L'
      AND p.fecha BETWEEN fecha1 AND fecha2
    GROUP BY p.recaud
    ORDER BY p.recaud;
END;
$$ LANGUAGE plpgsql;

-- ============================================

