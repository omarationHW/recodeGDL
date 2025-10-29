-- Stored Procedure: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene todos los tipos de aseo
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo() RETURNS TABLE (ctrol_aseo integer, tipo_aseo varchar, descripcion varchar, cta_aplicacion integer) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END; $$ LANGUAGE plpgsql;