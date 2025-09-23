-- Stored Procedure: sp_get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene todas las zonas
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_get_zonas() RETURNS TABLE (ctrol_zona integer, zona smallint, sub_zona smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY zona, sub_zona;
END; $$ LANGUAGE plpgsql;