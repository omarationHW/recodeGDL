-- Stored Procedure: sp_empresas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva empresa. Devuelve success y message.
-- Generado para formulario: Mannto_Empresas
-- Fecha: 2025-08-27 14:43:05

CREATE OR REPLACE FUNCTION sp_empresas_create(p_ctrol_emp INT, p_descripcion VARCHAR, p_representante VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT, num_empresa INT) AS $$
DECLARE
  v_max INT;
BEGIN
  SELECT COALESCE(MAX(num_empresa),0) INTO v_max FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_max + 1, p_ctrol_emp, p_descripcion, p_representante);
  RETURN QUERY SELECT TRUE, 'Empresa creada correctamente', v_max + 1;
EXCEPTION WHEN unique_violation THEN
  RETURN QUERY SELECT FALSE, 'Ya existe una empresa con ese número y tipo', NULL;
WHEN OTHERS THEN
  RETURN QUERY SELECT FALSE, 'Error al crear empresa: ' || SQLERRM, NULL;
END;
$$ LANGUAGE plpgsql;