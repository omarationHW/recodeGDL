-- Stored Procedure: sp_bloquear_cuenta
-- Tipo: CRUD
-- Descripción: Bloquea una cuenta para requerir (inserta en norequeribles).
-- Generado para formulario: bloqctasreqfrm
-- Fecha: 2025-08-26 20:48:43

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