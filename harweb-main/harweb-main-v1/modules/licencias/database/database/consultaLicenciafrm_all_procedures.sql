-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consultaLicenciafrm
-- Generado: 2025-08-27 17:25:29
-- Total SPs: 4
-- ============================================

-- SP 1/4: spget_lic_adeudos
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de una licencia (o anuncio) por año, incluyendo derechos, recargos, formas, etc.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spget_lic_adeudos(v_id integer, v_tipo varchar)
RETURNS TABLE(
  id_licencia integer,
  axo integer,
  licencia integer,
  anuncio integer,
  formas numeric,
  desc_formas numeric,
  derechos numeric,
  desc_derechos numeric,
  derechos2 numeric,
  recargos numeric,
  desc_recargos numeric,
  actualizacion numeric,
  gastos numeric,
  multas numeric,
  saldo numeric,
  concepto varchar,
  bloq varchar
) AS $$
BEGIN
  IF v_tipo = 'L' THEN
    RETURN QUERY
      SELECT d.id_licencia, d.axo, d.licencia, d.anuncio, d.formas, d.desc_formas, d.derechos, d.desc_derechos, d.derechos2, d.recargos, d.desc_recargos, d.actualizacion, d.gastos, d.multas, d.saldo, d.concepto, d.bloq
      FROM detsal_lic d
      WHERE d.id_licencia = v_id AND d.cvepago = 0;
  ELSIF v_tipo = 'A' THEN
    RETURN QUERY
      SELECT d.id_licencia, d.axo, d.licencia, d.anuncio, d.formas, d.desc_formas, d.derechos, d.desc_derechos, d.derechos2, d.recargos, d.desc_recargos, d.actualizacion, d.gastos, d.multas, d.saldo, d.concepto, d.bloq
      FROM detsal_lic d
      WHERE d.anuncio = v_id AND d.cvepago = 0;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia con un tipo de bloqueo y motivo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(p_id_licencia integer, p_tipo_bloqueo integer, p_motivo varchar)
RETURNS void AS $$
BEGIN
  UPDATE licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;
  INSERT INTO bloqueo (bloqueado, id_licencia, observa, vigente, fecha_mov, capturista)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, 'V', now(), current_user);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia para un tipo de bloqueo específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(p_id_licencia integer, p_tipo_bloqueo integer, p_motivo varchar)
RETURNS void AS $$
BEGIN
  UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND bloqueado = p_tipo_bloqueo AND vigente = 'V';
  UPDATE licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;
  INSERT INTO bloqueo (bloqueado, id_licencia, observa, vigente, fecha_mov, capturista)
    VALUES (0, p_id_licencia, p_motivo, 'V', now(), current_user);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: spget_lic_pagos
-- Tipo: Report
-- Descripción: Obtiene los pagos de una licencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spget_lic_pagos(p_id_licencia integer)
RETURNS TABLE(
  cvepago integer,
  cvecuenta integer,
  recaud smallint,
  caja varchar,
  folio integer,
  fecha date,
  hora timestamp,
  importe numeric,
  cajero varchar,
  cvecanc integer,
  cveconcepto integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT cvepago, cvecuenta, recaud, caja, folio, fecha, hora, importe, cajero, cvecanc, cveconcepto
    FROM pagos
    WHERE cvecuenta = p_id_licencia AND cveconcepto IN (8,27,28) AND cvecanc IS NULL
    ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

