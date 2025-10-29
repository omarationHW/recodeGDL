-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Catálogo de Ejecutores
-- Archivo: 23_SP_APREMIOSSVN_EJECUTORES_CATALOGO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3
-- ============================================

-- SP 1/3: SP_APREMIOSSVN_EJECUTORES_LISTAR
-- Tipo: Catalog
-- Descripción: Lista todos los ejecutores activos (OFICIO no vacío y VIGENCIA = 'V') ordenados por cve_eje.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTORES_LISTAR()
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    categoria VARCHAR(60),
    observacion VARCHAR(60),
    vigencia VARCHAR(1),
    comision NUMERIC,
    oficio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_ejecutor, e.cve_eje, e.ini_rfc, e.fec_rfc, e.hom_rfc, e.nombre, e.id_rec, e.categoria, e.observacion, e.vigencia, e.comision, e.oficio
    FROM public.ta_15_ejecutores e
    WHERE e.oficio IS NOT NULL AND e.oficio <> '' AND e.vigencia = 'V'
    ORDER BY e.cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: SP_APREMIOSSVN_EJECUTORES_BUSCAR_NOMBRE
-- Tipo: Catalog
-- Descripción: Busca ejecutores activos por nombre (búsqueda parcial, insensible a mayúsculas/minúsculas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTORES_BUSCAR_NOMBRE(p_nombre VARCHAR)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    recaudadora VARCHAR,
    categoria VARCHAR(60),
    observacion VARCHAR(60),
    vigencia VARCHAR(1),
    comision NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_ejecutor, e.cve_eje, e.ini_rfc, e.fec_rfc, e.hom_rfc, e.nombre, e.id_rec, r.recaudadora, e.categoria, e.observacion, e.vigencia, e.comision
    FROM public.ta_15_ejecutores e
    LEFT JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
    WHERE e.oficio IS NOT NULL AND e.oficio <> '' AND e.vigencia = 'V'
      AND UPPER(e.nombre) LIKE UPPER('%' || p_nombre || '%')
    ORDER BY e.cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: SP_APREMIOSSVN_EJECUTORES_BUSCAR_CVE
-- Tipo: Catalog
-- Descripción: Busca ejecutores activos por clave exacta o parcial (cve_eje).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTORES_BUSCAR_CVE(p_cve_eje VARCHAR)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    recaudadora VARCHAR,
    categoria VARCHAR(60),
    observacion VARCHAR(60),
    vigencia VARCHAR(1),
    comision NUMERIC,
    folios_asignados BIGINT,
    folios_practicados BIGINT,
    efectividad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_ejecutor, e.cve_eje, e.ini_rfc, e.fec_rfc, e.hom_rfc, e.nombre, e.id_rec, r.recaudadora, e.categoria, e.observacion, e.vigencia, e.comision,
    COALESCE(stats.folios_asignados, 0) as folios_asignados,
    COALESCE(stats.folios_practicados, 0) as folios_practicados,
    CASE WHEN COALESCE(stats.folios_asignados, 0) > 0 
         THEN ROUND((COALESCE(stats.folios_practicados, 0)::NUMERIC / stats.folios_asignados::NUMERIC) * 100, 2)
         ELSE 0 END as efectividad
    FROM public.ta_15_ejecutores e
    LEFT JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
    LEFT JOIN (
        SELECT ejecutor, zona,
               COUNT(*) as folios_asignados,
               COUNT(*) FILTER (WHERE clave_practicado = 'P') as folios_practicados
        FROM public.ta_15_apremios
        WHERE vigencia = '1' OR vigencia = '2'
        GROUP BY ejecutor, zona
    ) stats ON e.cve_eje = stats.ejecutor AND e.id_rec = stats.zona
    WHERE e.oficio IS NOT NULL AND e.oficio <> '' AND e.vigencia = 'V'
      AND CAST(e.cve_eje AS TEXT) LIKE p_cve_eje || '%'
    ORDER BY e.cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================