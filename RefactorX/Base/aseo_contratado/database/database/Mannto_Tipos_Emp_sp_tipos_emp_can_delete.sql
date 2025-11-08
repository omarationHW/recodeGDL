-- Stored Procedure: sp_tipos_emp_can_delete
-- Tipo: Catalog
-- Descripción: Verifica si un tipo de empresa puede ser eliminado (no tiene empresas asociadas).
-- Generado para formulario: Mannto_Tipos_Emp
-- Fecha: 2025-08-27 14:52:22

CREATE OR REPLACE FUNCTION sp_tipos_emp_can_delete(p_ctrol_emp INTEGER)
RETURNS TABLE(can_delete boolean) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF existe > 0 THEN
    RETURN QUERY SELECT false;
  ELSE
    RETURN QUERY SELECT true;
  END IF;
END;
$$ LANGUAGE plpgsql;