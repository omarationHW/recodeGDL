-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: UBICODIFICA (EXACTO del archivo original)
-- Archivo: 75_SP_RECAUDADORA_UBICODIFICA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_get_ubicodifica_data
-- Tipo: Catalog
-- Descripción: Obtiene los datos de contribuyente y codificación de ubicación para una cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ubicodifica_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    cvecalle INTEGER,
    calleu TEXT,
    extu TEXT,
    intu TEXT,
    cvereg INTEGER,
    descripcion TEXT,
    fec_alta DATE,
    usuario_alta TEXT,
    vigencia TEXT,
    fec_mov DATE,
    usuario_mov TEXT,
    fec_baja DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT contrib.nombre_completo, contrib.calle, contrib.noexterior, contrib.interior, catastro.ultcomp, catastro.axoultcomp, c.recaud, c.urbrus, c.cuenta, ub.cvecalle, ub.calle, ub.noexterior, ub.interior, regprop.cvereg, cal.descripcion, ur.fec_alta, ur.usuario_alta, ur.vigencia, ur.fec_mov, ur.usuario_mov, ur.fec_baja
    FROM catastro
    JOIN regprop ON regprop.cvecuenta = catastro.cvecuenta AND regprop.cveregprop = catastro.cveregprop AND regprop.encabeza = 'S'
    JOIN contrib ON contrib.cvecont = regprop.cvecont
    JOIN convcta c ON c.cvecuenta = catastro.cvecuenta
    JOIN ubicacion ub ON ub.cveubic = catastro.cveubic
    LEFT JOIN c_calidpro cal ON cal.cvereg = regprop.cvereg
    LEFT JOIN ubicacion_req ur ON ur.cvecuenta = catastro.cvecuenta
    WHERE catastro.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: UBICODIFICA (EXACTO del archivo original)
-- Archivo: 75_SP_RECAUDADORA_UBICODIFICA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_actualiza_ubicodifica
-- Tipo: CRUD
-- Descripción: Actualiza un registro de codificación de ubicación (reactiva o actualiza).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_actualiza_ubicodifica(p_cvecuenta INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE ubicacion_req
    SET fec_alta = CURRENT_DATE,
        usuario_alta = p_usuario,
        vigencia = 'V',
        fec_mov = CURRENT_DATE,
        fec_baja = NULL,
        usuario_mov = p_usuario
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: UBICODIFICA (EXACTO del archivo original)
-- Archivo: 75_SP_RECAUDADORA_UBICODIFICA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_listado_ubicodifica
-- Tipo: Report
-- Descripción: Listado de cuentas sin zona/subzona.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listado_ubicodifica(p_reca INTEGER, p_ctaini INTEGER, p_ctafin INTEGER)
RETURNS TABLE(
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    cvecatnva TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.recaud, c.urbrus, c.cuenta, c.cvecatnva, u.calle, u.noexterior, u.interior
    FROM convcta c
    JOIN catastro ct ON ct.cvecuenta = c.cvecuenta
    JOIN ubicacion u ON u.cveubic = ct.cveubic
    WHERE c.recaud = p_reca
      AND c.cuenta BETWEEN p_ctaini AND p_ctafin
      AND (substring(c.cip from 1 for 3) = '   ' OR c.cip IS NULL OR substring(c.cip from 1 for 1) = '0')
    ORDER BY c.recaud, c.cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

