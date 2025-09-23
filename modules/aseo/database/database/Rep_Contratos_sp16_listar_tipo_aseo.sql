-- Stored Procedure: sp16_listar_tipo_aseo
-- Tipo: Catalog
-- Descripción: Devuelve todos los tipos de aseo.
-- Generado para formulario: Rep_Contratos
-- Fecha: 2025-08-27 15:07:54

CREATE OR REPLACE FUNCTION sp16_listar_tipo_aseo()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo TEXT, descripcion TEXT, cta_aplicacion INTEGER) AS $$
BEGIN
  RETURN QUERY
  SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
  FROM ta_16_tipo_aseo
  ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;