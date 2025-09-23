-- Stored Procedure: sp_servicio_update
-- Tipo: CRUD
-- Descripción: Actualiza un servicio de obra pública
-- Generado para formulario: Servicio
-- Fecha: 2025-08-27 15:53:18

CREATE OR REPLACE FUNCTION sp_servicio_update(p_servicio smallint, p_descripcion varchar, p_serv_obra94 smallint)
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  UPDATE ta_17_servicios
    SET descripcion = p_descripcion,
        serv_obra94 = p_serv_obra94
    WHERE servicio = p_servicio;
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;