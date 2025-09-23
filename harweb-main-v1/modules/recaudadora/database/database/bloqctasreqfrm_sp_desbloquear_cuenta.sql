-- Stored Procedure: sp_desbloquear_cuenta
-- Tipo: CRUD
-- Descripción: Desbloquea una cuenta para requerir (actualiza norequeribles, pone user_baja y fecbaja).
-- Generado para formulario: bloqctasreqfrm
-- Fecha: 2025-08-26 20:48:43

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