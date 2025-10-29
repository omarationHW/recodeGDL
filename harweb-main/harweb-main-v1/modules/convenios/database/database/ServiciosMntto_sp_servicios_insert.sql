-- Stored Procedure: sp_servicios_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en ta_17_servicios
-- Generado para formulario: ServiciosMntto
-- Fecha: 2025-08-27 15:54:34

CREATE OR REPLACE FUNCTION sp_servicios_insert(p_servicio integer, p_descripcion text, p_serv_obra94 integer)
RETURNS TABLE(servicio integer, descripcion text, serv_obra94 integer) AS $$
BEGIN
    INSERT INTO ta_17_servicios(servicio, descripcion, serv_obra94)
    VALUES (p_servicio, p_descripcion, p_serv_obra94);
    RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;