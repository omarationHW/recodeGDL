-- Stored Procedure: sp_servicios_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_17_servicios
-- Generado para formulario: ServiciosMntto
-- Fecha: 2025-08-27 15:54:34

CREATE OR REPLACE FUNCTION sp_servicios_delete(p_servicio integer)
RETURNS TABLE(success boolean) AS $$
BEGIN
    DELETE FROM ta_17_servicios WHERE servicio = p_servicio;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;