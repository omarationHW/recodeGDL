-- Stored Procedure: sp_empresas_update
-- Tipo: CRUD
-- Descripción: Actualiza una empresa existente
-- Generado para formulario: Mannto_Empresas
-- Fecha: 2025-08-27 14:43:05

CREATE OR REPLACE FUNCTION sp_empresas_update(p_num_empresa INT, p_ctrol_emp INT, p_descripcion VARCHAR, p_representante VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  UPDATE ta_16_empresas SET descripcion = p_descripcion, representante = p_representante
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Empresa actualizada correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Empresa no encontrada';
  END IF;
END;
$$ LANGUAGE plpgsql;