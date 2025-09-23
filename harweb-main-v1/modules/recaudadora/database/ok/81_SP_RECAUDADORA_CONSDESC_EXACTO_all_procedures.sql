-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSDESC (EXACTO del archivo original)
-- Archivo: 81_SP_RECAUDADORA_CONSDESC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
    FROM descpred d
    JOIN convcta a ON d.cvecuenta = a.cvecuenta
    JOIN c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE (p_recaud IS NULL OR a.recaud = p_recaud)
      AND (p_cuenta IS NULL OR a.cuenta = p_cuenta)
      AND (p_propi IS NULL OR d.propie ILIKE '%' || p_propi || '%')
    ORDER BY d.propie;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSDESC (EXACTO del archivo original)
-- Archivo: 81_SP_RECAUDADORA_CONSDESC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
    SELECT cveinst, institucion FROM c_instituciones ORDER BY institucion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSDESC (EXACTO del archivo original)
-- Archivo: 81_SP_RECAUDADORA_CONSDESC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

