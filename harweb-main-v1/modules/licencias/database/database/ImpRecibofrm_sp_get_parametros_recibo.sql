-- Stored Procedure: sp_get_parametros_recibo
-- Tipo: Catalog
-- Descripción: Obtiene los costos de certificación y constancia
-- Generado para formulario: ImpRecibofrm
-- Fecha: 2025-08-27 18:32:11

CREATE OR REPLACE FUNCTION sp_get_parametros_recibo()
RETURNS TABLE(
    costo_certific NUMERIC,
    costo_constancia NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT costo_certific, costo_constancia FROM parametros_lic LIMIT 1;
END;
$$ LANGUAGE plpgsql;