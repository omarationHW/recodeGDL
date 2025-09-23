-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: BuscaRegistroModulo
-- Generado: 2025-08-27 13:53:23
-- Total SPs: 5
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

-- SP 2/5: sp_busca_registro_modulo_lic_construccion
-- Tipo: Catalog
-- Descripción: Busca registros de licencias de construcción usando segmentos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_lic_construccion(segmento1 TEXT, segmento2 TEXT, segmento3 TEXT)
RETURNS TABLE(control INT, nombre TEXT, calcregistro TEXT, modulo INT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM sp_encabezado(0, segmento1, segmento2, segmento3, ' ', ' ', ' ');
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/5: sp_busca_registro_modulo_mercados
-- Tipo: Catalog
-- Descripción: Busca registros de mercados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_mercados(oficina INT, num_mercado INT, categoria INT, seccion TEXT, local INT, letra_local TEXT, bloque TEXT)
RETURNS TABLE(control INT, oficina INT, num_mercado INT, categoria INT, seccion TEXT, local INT, letra_local TEXT, bloque TEXT, calcregistro TEXT, nombre TEXT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
         oficina||'-'||num_mercado||'-'||categoria||'-'||seccion||'-'||local||'-'||COALESCE(letra_local,' ')||'-'||COALESCE(bloque,' ') AS calcregistro,
         nombre, domicilio
  FROM ta_11_locales
  WHERE oficina = oficina
    AND num_mercado = num_mercado
    AND categoria = categoria
    AND seccion = seccion
    AND local = local
    AND (letra_local = letra_local OR letra_local IS NULL)
    AND (bloque = bloque OR bloque IS NULL)
    AND vigencia = 'A'
    AND bloqueo = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_encabezado
-- Tipo: Catalog
-- Descripción: Obtiene encabezado de licencias de construcción (simulación de SP externo)
-- --------------------------------------------

-- Simulación de SP externo, debe implementarse en la base de datos de licencias
-- CREATE OR REPLACE FUNCTION sp_encabezado(tynInterface INT, chSegmento1 TEXT, chSegmento2 TEXT, chSegmento3 TEXT, chSegmento4 TEXT, chSegmento5 TEXT, chSegmento6 TEXT)
-- RETURNS TABLE(control INT, nombre TEXT, calcregistro TEXT, modulo INT, ubicacion TEXT) AS $$ ... $$ LANGUAGE plpgsql;

-- ============================================

