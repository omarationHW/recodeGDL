-- Stored Procedure: rptservicios_get_all
-- Tipo: Report
-- Descripción: Obtiene todos los registros del catálogo de servicios, ordenados por servicio.
-- Generado para formulario: RptServicios
-- Fecha: 2025-08-27 15:51:52

CREATE OR REPLACE FUNCTION rptservicios_get_all()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT servicio, descripcion, serv_obra94
    FROM ta_17_servicios
    ORDER BY servicio;
END;
$$;