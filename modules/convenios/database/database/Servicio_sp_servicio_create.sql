-- Stored Procedure: sp_servicio_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo servicio de obra pública
-- Generado para formulario: Servicio
-- Fecha: 2025-08-27 15:53:18

CREATE OR REPLACE FUNCTION sp_servicio_create(p_descripcion varchar, p_serv_obra94 smallint)
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
DECLARE
  new_id smallint;
BEGIN
  SELECT COALESCE(MAX(servicio), 0) + 1 INTO new_id FROM ta_17_servicios;
  INSERT INTO ta_17_servicios(servicio, descripcion, serv_obra94)
    VALUES (new_id, p_descripcion, p_serv_obra94)
    RETURNING servicio, descripcion, serv_obra94 INTO new_id, p_descripcion, p_serv_obra94;
  RETURN QUERY SELECT new_id, p_descripcion, p_serv_obra94;
END;
$$ LANGUAGE plpgsql;