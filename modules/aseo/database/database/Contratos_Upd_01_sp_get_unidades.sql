-- Stored Procedure: sp_get_unidades
-- Tipo: Catalog
-- Descripción: Obtiene unidades de recolección por ejercicio
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_get_unidades(ejercicio integer) RETURNS TABLE (ctrol_recolec integer, cve_recolec varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_recolec, cve_recolec, descripcion FROM ta_16_unidades WHERE ejercicio_recolec = ejercicio ORDER BY ctrol_recolec;
END; $$ LANGUAGE plpgsql;