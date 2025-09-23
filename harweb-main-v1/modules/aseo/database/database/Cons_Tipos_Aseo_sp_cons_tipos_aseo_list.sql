-- Stored Procedure: sp_cons_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Devuelve la lista de tipos de aseo ordenada por el campo solicitado.
-- Generado para formulario: Cons_Tipos_Aseo
-- Fecha: 2025-08-27 14:02:37

CREATE OR REPLACE FUNCTION sp_cons_tipos_aseo_list(p_order text DEFAULT 'ctrol_aseo')
RETURNS TABLE(ctrol_aseo integer, tipo_aseo varchar, descripcion varchar) AS $$
DECLARE
  sql text;
BEGIN
  IF p_order NOT IN ('ctrol_aseo', 'tipo_aseo', 'descripcion') THEN
    p_order := 'ctrol_aseo';
  END IF;
  sql := format('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY %I', p_order);
  RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;