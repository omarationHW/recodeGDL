-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCAREGISTROMODULO (EXACTO del archivo original)
-- Archivo: 29_SP_CONVENIOS_BUSCAREGISTROMODULO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_busca_registro_modulo_multas
-- Tipo: Catalog
-- Descripción: Busca registros de multas municipales y federales según parámetros
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_multas(abrevia TEXT, axo_acta INT, num_acta INT)
RETURNS TABLE(control INT, abrevia TEXT, axo_acta INT, num_acta INT, nombre TEXT, calcregistro TEXT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT b.id_multa, a.abrevia, b.axo_acta, b.num_acta, b.contribuyente,
         TRIM(a.abrevia)||'-'||b.axo_acta||'-'||b.num_acta AS calcregistro,
         b.domicilio
  FROM c_dependencias a, multas b
  WHERE a.abrevia = abrevia
    AND b.id_dependencia = a.id_dependencia
    AND b.axo_acta = axo_acta
    AND b.num_acta = num_acta
    AND b.fecha_cancelacion IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCAREGISTROMODULO (EXACTO del archivo original)
-- Archivo: 29_SP_CONVENIOS_BUSCAREGISTROMODULO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_busca_registro_modulo_predial
-- Tipo: Catalog
-- Descripción: Busca registros de predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_predial(recaud TEXT, urbrus TEXT, cuenta TEXT)
RETURNS TABLE(control INT, nombre TEXT, calcregistro TEXT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT e.cvecuenta, c.nombre_completo, e.recaud||'-'||e.urbrus||'-'||e.cuenta, d.calle||d.noexterior
  FROM convcta e, catastro a, regprop b, contrib c, ubicacion d
  WHERE e.recaud = recaud
    AND e.urbrus = urbrus
    AND e.cuenta = cuenta
    AND e.vigente = 'V'
    AND a.cvecuenta = e.cvecuenta
    AND b.cvecuenta = a.cvecuenta
    AND b.cveregprop = a.cveregprop
    AND c.cvecont = b.cvecont
    AND b.encabeza = 'S'
    AND d.cvecuenta = e.cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCAREGISTROMODULO (EXACTO del archivo original)
-- Archivo: 29_SP_CONVENIOS_BUSCAREGISTROMODULO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_encabezado
-- Tipo: Catalog
-- Descripción: Obtiene encabezado de licencias de construcción (simulación de SP externo)
-- --------------------------------------------

-- Simulación de SP externo, debe implementarse en la base de datos de licencias
-- CREATE OR REPLACE FUNCTION sp_encabezado(tynInterface INT, chSegmento1 TEXT, chSegmento2 TEXT, chSegmento3 TEXT, chSegmento4 TEXT, chSegmento5 TEXT, chSegmento6 TEXT)
-- RETURNS TABLE(control INT, nombre TEXT, calcregistro TEXT, modulo INT, ubicacion TEXT) AS $$ ... $$ LANGUAGE plpgsql;

-- ============================================

