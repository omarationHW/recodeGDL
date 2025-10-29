-- Stored Procedure: sp_grabainconf
-- Tipo: CRUD
-- Descripción: Envía cuentas bloqueadas a Catastro/Inconformidades y marca lote_envio y fecha_envio.
-- Generado para formulario: bloqctasreqfrm
-- Fecha: 2025-08-26 20:48:43

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