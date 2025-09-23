-- Stored Procedure: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa si no tiene contratos asociados
-- Generado para formulario: ABC_Empresas
-- Fecha: 2025-08-27 13:23:03

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_num_empresa INTEGER, p_ctrol_emp INTEGER) RETURNS INTEGER AS $$
DECLARE
  v_contratos INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_contratos FROM ta_16_contratos WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF v_contratos > 0 THEN
    RETURN 0;
  END IF;
  DELETE FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  RETURN 1;
END;
$$ LANGUAGE plpgsql;