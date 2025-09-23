-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ImpLicenciaReglamentadaFrm
-- Generado: 2025-08-27 18:28:55
-- Total SPs: 2
-- ============================================

-- SP 1/2: calc_adeudolic
-- Tipo: CRUD
-- Descripción: Calcula el adeudo de una licencia y llena la tabla temporal tmp_adeudolic para impresión.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_adeudolic(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
  -- Limpiar temporal para la licencia
  DELETE FROM tmp_adeudolic WHERE id_licencia = p_id_licencia;

  -- Insertar adeudos de licencias
  INSERT INTO tmp_adeudolic (id_licencia, numero, texto, ctaapl, importe)
  SELECT l.id_licencia, g.descripcion, g.ctaaplic, 'LIC', COALESCE(s.saldo,0)
  FROM licencias l
  JOIN c_giros g ON g.id_giro = l.id_giro
  JOIN detsal_lic s ON s.id_licencia = l.id_licencia AND s.id_anuncio = 0 AND s.cvepago = 0
  WHERE l.id_licencia = p_id_licencia AND l.vigente = 'V';

  -- Insertar adeudos de anuncios
  INSERT INTO tmp_adeudolic (id_licencia, numero, texto, ctaapl, importe)
  SELECT a.id_licencia, g.descripcion, g.ctaaplic, 'ANU', COALESCE(s.saldo,0)
  FROM anuncios a
  JOIN c_giros g ON g.id_giro = a.id_giro
  JOIN detsal_lic s ON s.id_anuncio = a.id_anuncio AND s.cvepago = 0
  WHERE a.id_licencia = p_id_licencia AND a.vigente = 'V' AND a.misma_forma = 'S';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: detsaldo_licencia
-- Tipo: Report
-- Descripción: Devuelve el detalle de saldo de una licencia (licencia y anuncios).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION detsaldo_licencia(p_id_licencia INTEGER)
RETURNS TABLE(numero INTEGER, descripcion TEXT, ctaaplic INTEGER, forma TEXT, derechos NUMERIC, recargos NUMERIC, saldo NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT l.id_licencia, g.descripcion, g.ctaaplic, 'LIC', s.derechos, s.recargos, s.saldo
  FROM licencias l
  JOIN c_giros g ON g.id_giro = l.id_giro
  JOIN detsal_lic s ON s.id_licencia = l.id_licencia AND s.id_anuncio = 0 AND s.cvepago = 0
  WHERE l.id_licencia = p_id_licencia AND l.vigente = 'V'

  UNION

  SELECT a.id_anuncio, g.descripcion, g.ctaaplic, 'ANU', s.derechos, s.recargos, s.saldo
  FROM anuncios a
  JOIN c_giros g ON g.id_giro = a.id_giro
  JOIN detsal_lic s ON s.id_anuncio = a.id_anuncio AND s.cvepago = 0
  WHERE a.id_licencia = p_id_licencia AND a.vigente = 'V' AND a.misma_forma = 'S';
END;
$$ LANGUAGE plpgsql;

-- ============================================

