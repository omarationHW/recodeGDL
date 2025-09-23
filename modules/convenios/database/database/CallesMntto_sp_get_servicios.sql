-- Stored Procedure: sp_get_servicios
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de servicios
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_get_servicios() RETURNS TABLE(servicio smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion FROM ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;