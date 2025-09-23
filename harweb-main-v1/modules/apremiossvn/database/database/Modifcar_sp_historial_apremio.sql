-- Stored Procedure: sp_historial_apremio
-- Tipo: Catalog
-- Descripción: Devuelve el historial de cambios de un folio de apremio
-- Generado para formulario: Modifcar
-- Fecha: 2025-08-27 20:53:04

CREATE OR REPLACE FUNCTION sp_historial_apremio(p_id_control integer)
RETURNS TABLE (
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    observaciones varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha_actualiz, usuario, clave_mov, observaciones
    FROM ta_15_historia
    WHERE id_control = p_id_control
    ORDER BY fecha_actualiz DESC;
END;
$$ LANGUAGE plpgsql;