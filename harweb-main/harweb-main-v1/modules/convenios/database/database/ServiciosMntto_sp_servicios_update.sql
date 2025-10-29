-- Stored Procedure: sp_servicios_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en ta_17_servicios
-- Generado para formulario: ServiciosMntto
-- Fecha: 2025-08-27 15:54:34

CREATE OR REPLACE FUNCTION sp_servicios_update(p_servicio integer, p_descripcion text, p_serv_obra94 integer)
RETURNS TABLE(servicio integer, descripcion text, serv_obra94 integer) AS $$
BEGIN
    UPDATE ta_17_servicios
    SET descripcion = p_descripcion,
        serv_obra94 = p_serv_obra94
    WHERE servicio = p_servicio;
    RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;