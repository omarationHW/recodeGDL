-- Stored Procedure: sp_servicio_show
-- Tipo: Catalog
-- Descripción: Obtiene un servicio por ID
-- Generado para formulario: Servicio
-- Fecha: 2025-08-27 15:53:18

CREATE OR REPLACE FUNCTION sp_servicio_show(p_servicio smallint)
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;