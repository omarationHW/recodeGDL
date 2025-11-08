-- Stored Procedure: sp_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa si no tiene empresas asociadas.
-- Generado para formulario: Mannto_Tipos_Emp
-- Fecha: 2025-08-27 14:52:22

CREATE OR REPLACE FUNCTION sp_tipos_emp_delete(p_ctrol_emp INTEGER)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas.';
    RETURN;
  END IF;
  DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente';
END;
$$ LANGUAGE plpgsql;