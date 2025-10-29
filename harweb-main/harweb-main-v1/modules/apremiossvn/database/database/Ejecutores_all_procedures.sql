-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Ejecutores
-- Generado: 2025-08-27 13:44:05
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_ejecutores_listar
-- Tipo: Catalog
-- Descripción: Lista todos los ejecutores activos (OFICIO no vacío y VIGENCIA = 'A') ordenados por cve_eje.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_listar()
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    categoria VARCHAR(60),
    observacion VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion
    FROM ta_15_ejecutores
    WHERE oficio IS NOT NULL AND oficio <> '' AND vigencia = 'A'
    ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_ejecutores_buscar_nombre
-- Tipo: Catalog
-- Descripción: Busca ejecutores activos por nombre (búsqueda parcial, insensible a mayúsculas/minúsculas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_buscar_nombre(p_nombre VARCHAR)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    categoria VARCHAR(60),
    observacion VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion
    FROM ta_15_ejecutores
    WHERE oficio IS NOT NULL AND oficio <> '' AND vigencia = 'A'
      AND unaccent(upper(nombre)) LIKE unaccent(upper('%' || p_nombre || '%'))
    ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_ejecutores_buscar_cve
-- Tipo: Catalog
-- Descripción: Busca ejecutores activos por clave exacta o parcial (cve_eje).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_buscar_cve(p_cve_eje VARCHAR)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    categoria VARCHAR(60),
    observacion VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion
    FROM ta_15_ejecutores
    WHERE oficio IS NOT NULL AND oficio <> '' AND vigencia = 'A'
      AND CAST(cve_eje AS TEXT) LIKE p_cve_eje || '%'
    ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

