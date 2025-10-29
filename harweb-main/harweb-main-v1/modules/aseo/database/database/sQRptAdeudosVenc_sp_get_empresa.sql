-- Stored Procedure: sp_get_empresa
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la empresa por num_empresa y ctrol_emp.
-- Generado para formulario: sQRptAdeudosVenc
-- Fecha: 2025-08-27 15:24:46

CREATE OR REPLACE FUNCTION sp_get_empresa(p_num_empresa integer, p_ctrol_emp integer)
RETURNS TABLE(num_empresa integer, ctrol_emp integer, descripcion varchar, representante varchar) AS $$
BEGIN
    RETURN QUERY
    SELECT num_empresa, ctrol_emp, descripcion, representante
    FROM ta_16_empresas
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;