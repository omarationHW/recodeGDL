-- Stored Procedure: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo por año-mes
-- Generado para formulario: Mannto_Recargos
-- Fecha: 2025-08-27 14:47:49

CREATE OR REPLACE FUNCTION sp_recargos_delete(p_year INTEGER, p_month INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT FALSE, 'No existe recargo para ese periodo';
    RETURN;
  END IF;
  DELETE FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  RETURN QUERY SELECT TRUE, 'Recargo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;