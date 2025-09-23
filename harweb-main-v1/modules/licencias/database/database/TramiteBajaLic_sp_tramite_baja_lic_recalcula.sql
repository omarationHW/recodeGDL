-- Stored Procedure: sp_tramite_baja_lic_recalcula
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de la licencia y actualiza los importes proporcionales según reglas de negocio.
-- Generado para formulario: TramiteBajaLic
-- Fecha: 2025-08-27 19:47:43

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_recalcula(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
BEGIN
  SELECT * INTO v_licencia FROM licencias WHERE licencia = p_licencia;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;
  -- Aquí se puede llamar a un SP que recalcula los saldos proporcionales
  PERFORM calc_sdosl(v_licencia.id_licencia);
  RETURN json_build_object('success', true, 'message', 'Recalculo realizado');
END;
$$ LANGUAGE plpgsql;