-- Stored Procedure: get_individual_folio_periods
-- Tipo: Report
-- Descripción: Obtiene los periodos asociados a un folio individual
-- Generado para formulario: Individual
-- Fecha: 2025-08-27 13:52:12

CREATE OR REPLACE FUNCTION get_individual_folio_periods(id_control integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo integer,
    importe numeric,
    recargos numeric,
    cantidad numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_periodos WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;