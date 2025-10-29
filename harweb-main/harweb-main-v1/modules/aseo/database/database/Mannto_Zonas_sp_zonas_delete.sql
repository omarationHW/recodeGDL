-- Stored Procedure: sp_zonas_delete
-- Tipo: Catalog
-- Descripción: Elimina una zona si no tiene empresas dependientes.
-- Generado para formulario: Mannto_Zonas
-- Fecha: 2025-08-27 14:55:29

CREATE OR REPLACE FUNCTION sp_zonas_delete(p_ctrol_zona integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_emp integer;
BEGIN
  SELECT COUNT(*) INTO v_emp FROM ta_16_empresas WHERE ctrol_zona = p_ctrol_zona;
  IF v_emp > 0 THEN
    RETURN QUERY SELECT false, 'Existen empresas con esta zona. No se puede borrar.';
    RETURN;
  END IF;
  DELETE FROM ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
  RETURN QUERY SELECT true, 'Zona eliminada correctamente';
END;
$$ LANGUAGE plpgsql;