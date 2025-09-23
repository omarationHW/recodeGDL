-- Stored Procedure: sp_get_remesa_detalle_edo
-- Tipo: Report
-- Descripción: Obtiene el detalle de una remesa del estado (tabla ta14_datos_edo) por nombre de remesa.
-- Generado para formulario: ConsRemesas
-- Fecha: 2025-08-27 13:30:41

CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_edo(remesa_param character varying)
RETURNS SETOF ta14_datos_edo AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta14_datos_edo WHERE remesa = remesa_param;
END;
$$ LANGUAGE plpgsql;