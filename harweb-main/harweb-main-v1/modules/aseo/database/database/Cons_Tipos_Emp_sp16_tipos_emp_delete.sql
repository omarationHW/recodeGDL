-- Stored Procedure: sp16_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa si no tiene empresas asociadas.
-- Generado para formulario: Cons_Tipos_Emp
-- Fecha: 2025-08-27 14:04:20

CREATE OR REPLACE FUNCTION sp16_tipos_emp_delete(p_ctrol_emp INTEGER)
RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
  cnt INTEGER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF cnt > 0 THEN
    RETURN QUERY SELECT 'error', 'No se puede eliminar: existen empresas asociadas.';
    RETURN;
  END IF;
  DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT 'ok', 'Eliminado correctamente.';
END;
$$ LANGUAGE plpgsql;