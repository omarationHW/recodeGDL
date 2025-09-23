-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: bloqctasreqfrm
-- Generado: 2025-08-26 20:48:43
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_grabainconf
-- Tipo: CRUD
-- Descripción: Envía cuentas bloqueadas a Catastro/Inconformidades y marca lote_envio y fecha_envio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_grabainconf(p_recaud integer, p_user text) RETURNS integer AS $$
DECLARE
  v_count integer := 0;
  v_lote integer;
BEGIN
  -- Obtener siguiente lote
  SELECT COALESCE(MAX(lote_envio),0)+1 INTO v_lote FROM norequeribles WHERE recaud = p_recaud;
  -- Actualizar registros
  UPDATE norequeribles SET lote_envio = v_lote, fecha_envio = CURRENT_DATE
    WHERE recaud = p_recaud AND lote_envio IS NULL AND fecha_envio IS NULL AND user_baja IS NULL;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: spd_norequeribles
-- Tipo: CRUD
-- Descripción: Desbloqueo masivo de cuentas bloqueadas (pone user_baja y fecbaja a todas las cuentas bloqueadas sin desbloquear).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_norequeribles(p_user text) RETURNS integer AS $$
DECLARE
  v_count integer := 0;
BEGIN
  UPDATE norequeribles SET user_baja = p_user, fecbaja = CURRENT_DATE
    WHERE user_baja IS NULL;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_bloquear_cuenta
-- Tipo: CRUD
-- Descripción: Bloquea una cuenta para requerir (inserta en norequeribles).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloquear_cuenta(
    p_recaud integer, p_urbrus text, p_cuenta integer, p_cvecuenta integer,
    p_motivo text, p_usuario text, p_fecha_desbloqueo date, p_tipo_bloq integer DEFAULT 200,
    p_fecha_envio date DEFAULT NULL, p_lote_envio integer DEFAULT NULL
) RETURNS integer AS $$
DECLARE
  v_id integer;
BEGIN
  INSERT INTO norequeribles (recaud, urbrus, cuenta, cvecuenta, feccap, capturista, observacion, fecbaja, tipo_bloq, fecha_envio, lote_envio)
  VALUES (p_recaud, p_urbrus, p_cuenta, p_cvecuenta, CURRENT_DATE, p_usuario, p_motivo, p_fecha_desbloqueo, p_tipo_bloq, p_fecha_envio, p_lote_envio)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_desbloquear_cuenta
-- Tipo: CRUD
-- Descripción: Desbloquea una cuenta para requerir (actualiza norequeribles, pone user_baja y fecbaja).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desbloquear_cuenta(
    p_cvecuenta integer, p_usuario text, p_motivo text, p_fecha_desbloqueo date
) RETURNS integer AS $$
DECLARE
  v_id integer;
BEGIN
  UPDATE norequeribles SET user_baja = p_usuario, fecbaja = p_fecha_desbloqueo, observacion = observacion || '\n' || p_motivo, tipo_bloq = 200
  WHERE cvecuenta = p_cvecuenta AND user_baja IS NULL
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

