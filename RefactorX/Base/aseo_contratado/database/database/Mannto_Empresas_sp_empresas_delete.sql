-- Stored Procedure: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa si no tiene contratos asociados
-- Generado para formulario: Mannto_Empresas
-- Fecha: 2025-08-27 14:43:05

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_num_empresa INT, p_ctrol_emp INT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ta_16_contratos WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF v_count > 0 THEN
    RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.';
  END IF;
  DELETE FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Empresa eliminada correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Empresa no encontrada';
  END IF;
END;
$$ LANGUAGE plpgsql;