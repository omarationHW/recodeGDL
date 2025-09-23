-- Stored Procedure: get_totales_by_concesion
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos agrupados por concepto para un local/concesión.
-- Generado para formulario: RConsulta
-- Fecha: 2025-08-28 13:38:15

CREATE OR REPLACE FUNCTION get_totales_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    cuenta INTEGER,
    obliga TEXT,
    concepto TEXT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe
    FROM cob34_rtotade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;