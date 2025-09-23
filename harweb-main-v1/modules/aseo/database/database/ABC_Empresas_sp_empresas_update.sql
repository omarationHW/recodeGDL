-- Stored Procedure: sp_empresas_update
-- Tipo: CRUD
-- Descripción: Actualiza una empresa existente
-- Generado para formulario: ABC_Empresas
-- Fecha: 2025-08-27 13:23:03

CREATE OR REPLACE FUNCTION sp_empresas_update(p_num_empresa INTEGER, p_ctrol_emp INTEGER, p_descripcion VARCHAR, p_representante VARCHAR) RETURNS INTEGER AS $$
BEGIN
  UPDATE ta_16_empresas SET descripcion = p_descripcion, representante = p_representante
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;