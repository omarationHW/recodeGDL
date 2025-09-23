-- Stored Procedure: spd_norequeribles
-- Tipo: CRUD
-- Descripción: Desbloqueo masivo de cuentas bloqueadas (pone user_baja y fecbaja a todas las cuentas bloqueadas sin desbloquear).
-- Generado para formulario: bloqctasreqfrm
-- Fecha: 2025-08-26 20:48:43

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