-- Stored Procedure: sp_individual_folio_periods
-- Tipo: Report
-- Descripción: Devuelve los periodos asociados al folio (tabla ta_15_periodos) para un id_control.
-- Generado para formulario: Individual_Folio
-- Fecha: 2025-08-27 13:54:03

CREATE OR REPLACE FUNCTION sp_individual_folio_periods(p_id_control integer)
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
    SELECT * FROM ta_15_periodos WHERE control_otr = p_id_control ORDER BY ayo, periodo;
END;
$$ LANGUAGE plpgsql;