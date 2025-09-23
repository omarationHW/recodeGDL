-- Stored Procedure: sp_ejecutores_toggle_vigencia
-- Tipo: CRUD
-- Descripción: Cambia la vigencia de un ejecutor (baja/reactiva)
-- Generado para formulario: ABCEjec
-- Fecha: 2025-08-27 13:29:40

CREATE OR REPLACE FUNCTION sp_ejecutores_toggle_vigencia(p_cve_eje integer, p_id_rec smallint)
RETURNS TABLE (result text) AS $$
DECLARE
  v_actual char(1);
BEGIN
  SELECT vigencia INTO v_actual FROM ta_15_ejecutores WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
  IF v_actual IS NULL THEN
    RETURN QUERY SELECT 'No existe ejecutor';
    RETURN;
  END IF;
  IF v_actual = 'A' THEN
    UPDATE ta_15_ejecutores SET vigencia = 'B' WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    RETURN QUERY SELECT 'Baja';
  ELSE
    UPDATE ta_15_ejecutores SET vigencia = 'A' WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    RETURN QUERY SELECT 'Reactivado';
  END IF;
END;
$$ LANGUAGE plpgsql;