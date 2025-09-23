-- Stored Procedure: sp_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa (solo si no tiene empresas asociadas)
-- Generado para formulario: ABC_Tipos_Emp
-- Fecha: 2025-08-27 13:29:55

CREATE OR REPLACE FUNCTION sp_tipos_emp_delete(p_ctrol_emp integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_empresas integer;
BEGIN
  SELECT COUNT(*) INTO v_empresas FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF v_empresas > 0 THEN
    RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas a este tipo';
    RETURN;
  END IF;
  DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente';
END;
$$ LANGUAGE plpgsql;