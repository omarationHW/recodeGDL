-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DDERECHOSLIC (EXACTO del archivo original)
-- Archivo: 89_SP_RECAUDADORA_DDERECHOSLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 1/8: sp_buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca licencia por folio y retorna datos principales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_licencia(p_folio INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.derechos>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.derechos>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM public l
    JOIN saldos_lic s ON l.id_licencia=s.id_licencia
    WHERE l.licencia=p_folio AND s.derechos>0 AND l.vigente='V' AND COALESCE(l.bloqueado,0)=0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DDERECHOSLIC (EXACTO del archivo original)
-- Archivo: 89_SP_RECAUDADORA_DDERECHOSLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 3/8: sp_buscar_forma
-- Tipo: Catalog
-- Descripción: Busca formas por folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_forma(p_folio INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.forma>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.forma>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM public l
    JOIN saldos_lic s ON l.id_licencia=s.id_licencia
    WHERE l.licencia=p_folio AND s.formas>0 AND l.vigente='V' AND l.bloqueado=0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DDERECHOSLIC (EXACTO del archivo original)
-- Archivo: 89_SP_RECAUDADORA_DDERECHOSLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 5/8: sp_buscar_descuento
-- Tipo: Catalog
-- Descripción: Busca descuentos vigentes para licencia/anuncio/forma
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_descuento(p_tipo TEXT, p_folio INTEGER)
RETURNS TABLE(id_descto INTEGER, tipo TEXT, licencia INTEGER, porcentaje INTEGER, fecalta DATE, captalta TEXT, fecbaja DATE, captbaja TEXT, estado TEXT, cvepago INTEGER, axoini INTEGER, axofin INTEGER, autoriza INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT id_descto, tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, axoini, axofin, autoriza
    FROM descderlic
    WHERE tipo=p_tipo AND licencia=p_folio AND estado='V';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DDERECHOSLIC (EXACTO del archivo original)
-- Archivo: 89_SP_RECAUDADORA_DDERECHOSLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 7/8: sp_cancelar_descuento
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelar_descuento(p_id_descto INTEGER, p_licencia INTEGER, p_user TEXT)
RETURNS TABLE(result TEXT) AS $$
BEGIN
  UPDATE descderlic
  SET estado='C', fecbaja=CURRENT_DATE, captbaja=p_user
  WHERE licencia=p_licencia AND id_descto=p_id_descto;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DDERECHOSLIC (EXACTO del archivo original)
-- Archivo: 89_SP_RECAUDADORA_DDERECHOSLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

