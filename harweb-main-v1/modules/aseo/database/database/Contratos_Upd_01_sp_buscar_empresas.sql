-- Stored Procedure: sp_buscar_empresas
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE)
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_buscar_empresas(nombre varchar) RETURNS TABLE (num_empresa integer, ctrol_emp integer, descripcion varchar, representante varchar) AS $$
BEGIN
  RETURN QUERY SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante
    FROM ta_16_empresas a, ta_16_tipos_emp b
    WHERE a.descripcion ILIKE '%' || nombre || '%' AND b.ctrol_emp = a.ctrol_emp
    ORDER BY a.num_empresa;
END; $$ LANGUAGE plpgsql;