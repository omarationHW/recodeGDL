-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSULTALICENCIAFRM (EXACTO del archivo original)
-- Archivo: 54_SP_LICENCIAS_CONSULTALICENCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSULTALICENCIAFRM (EXACTO del archivo original)
-- Archivo: 54_SP_LICENCIAS_CONSULTALICENCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSULTALICENCIAFRM (EXACTO del archivo original)
-- Archivo: 54_SP_LICENCIAS_CONSULTALICENCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

