-- Stored Procedure: sp_empresas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva empresa
-- Generado para formulario: ABC_Empresas
-- Fecha: 2025-08-27 13:23:03

CREATE OR REPLACE FUNCTION sp_empresas_create(p_ctrol_emp INTEGER, p_descripcion VARCHAR, p_representante VARCHAR) RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER) AS $$
DECLARE
  v_num_empresa INTEGER;
BEGIN
  SELECT COALESCE(MAX(num_empresa),0)+1 INTO v_num_empresa FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_num_empresa, p_ctrol_emp, p_descripcion, p_representante);
  RETURN QUERY SELECT v_num_empresa, p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;