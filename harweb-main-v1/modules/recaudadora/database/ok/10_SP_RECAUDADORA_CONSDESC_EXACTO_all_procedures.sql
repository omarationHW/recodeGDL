-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consdesc
-- Generado: 2025-08-26 23:20:34
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_consdesc_list
-- Tipo: Report
-- Descripción: Obtiene el listado general de descuentos prediales con filtros opcionales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consdesc_list(
    p_recaud INTEGER DEFAULT NULL,
    p_cuenta INTEGER DEFAULT NULL,
    p_propi TEXT DEFAULT NULL
) RETURNS TABLE (
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud_desc SMALLINT,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion SMALLINT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.recaud, a.urbrus, a.cuenta, d.*, c.descripcion
    FROM public.descpred d
    JOIN public.convcta a ON d.cvecuenta = a.cvecuenta
    JOIN public.c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE (p_recaud IS NULL OR a.recaud = p_recaud)
      AND (p_cuenta IS NULL OR a.cuenta = p_cuenta)
      AND (p_propi IS NULL OR d.propie ILIKE '%' || p_propi || '%')
    ORDER BY d.propie;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_consdesc_search
-- Tipo: Report
-- Descripción: Búsqueda avanzada de descuentos prediales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consdesc_search(
    p_propi TEXT DEFAULT NULL,
    p_foliodesc INTEGER DEFAULT NULL,
    p_recaud INTEGER DEFAULT NULL,
    p_identificacion TEXT DEFAULT NULL,
    p_solicitante TEXT DEFAULT NULL,
    p_institucion INTEGER DEFAULT NULL
) RETURNS TABLE (
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud_desc SMALLINT,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion SMALLINT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.recaud, a.urbrus, a.cuenta, d.*, c.descripcion
    FROM public.descpred d
    JOIN public.convcta a ON d.cvecuenta = a.cvecuenta
    JOIN public.c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE (p_propi IS NULL OR d.propie ILIKE '%' || p_propi || '%')
      AND (p_foliodesc IS NULL OR d.foliodesc = p_foliodesc)
      AND (p_recaud IS NULL OR d.recaud = p_recaud)
      AND (p_identificacion IS NULL OR d.identificacion ILIKE '%' || p_identificacion || '%')
      AND (p_solicitante IS NULL OR d.solicitante ILIKE '%' || p_solicitante || '%')
      AND (p_institucion IS NULL OR d.institucion = p_institucion)
    ORDER BY d.propie;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_consdesc_instituciones
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de instituciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consdesc_instituciones()
RETURNS TABLE (
    cveinst INTEGER,
    institucion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveinst, institucion FROM public.c_instituciones ORDER BY institucion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_consdesc_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de un descuento por folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consdesc_detalle(p_foliodesc INTEGER)
RETURNS TABLE (
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud_desc SMALLINT,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion SMALLINT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.recaud, a.urbrus, a.cuenta, d.*, c.descripcion
    FROM public.descpred d
    JOIN public.convcta a ON d.cvecuenta = a.cvecuenta
    JOIN public.c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.foliodesc = p_foliodesc;
END;
$$ LANGUAGE plpgsql;

-- ============================================