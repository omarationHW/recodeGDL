-- Stored Procedure: sp16_buscar_empresas
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE).
-- Generado para formulario: Rep_Contratos
-- Fecha: 2025-08-27 15:07:54

CREATE OR REPLACE FUNCTION sp16_buscar_empresas(nombre TEXT)
RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER, descripcion TEXT, representante TEXT, tipo_empresa TEXT, descripcion_1 TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante, b.tipo_empresa, b.descripcion
  FROM ta_16_empresas a
  JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
  WHERE a.descripcion ILIKE '%' || nombre || '%'
  ORDER BY a.num_empresa;
END;
$$ LANGUAGE plpgsql;