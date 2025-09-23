-- Stored Procedure: sp_servicio_delete
-- Tipo: CRUD
-- Descripción: Elimina un servicio de obra pública
-- Generado para formulario: Servicio
-- Fecha: 2025-08-27 15:53:18

CREATE OR REPLACE FUNCTION sp_servicio_delete(p_servicio smallint)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  DELETE FROM ta_17_servicios WHERE servicio = p_servicio;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Servicio eliminado correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Servicio no encontrado';
  END IF;
END;
$$ LANGUAGE plpgsql;