-- Stored Procedure: sp_servicio_report
-- Tipo: Report
-- Descripción: Reporte de catálogo de servicios (para impresión)
-- Generado para formulario: Servicio
-- Fecha: 2025-08-27 15:53:18

CREATE OR REPLACE FUNCTION sp_servicio_report()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;