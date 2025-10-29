-- Stored Procedure: sp_servicio_list
-- Tipo: Catalog
-- Descripción: Lista todos los servicios de obra pública
-- Generado para formulario: Servicio
-- Fecha: 2025-08-27 15:53:18

CREATE OR REPLACE FUNCTION sp_servicio_list()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;