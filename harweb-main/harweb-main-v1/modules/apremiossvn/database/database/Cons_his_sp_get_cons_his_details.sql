-- Stored Procedure: sp_get_cons_his_details
-- Tipo: Report
-- Descripción: Obtiene los detalles de periodos asociados al control_otr.
-- Generado para formulario: Cons_his
-- Fecha: 2025-08-27 13:42:45

CREATE OR REPLACE FUNCTION sp_get_cons_his_details(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric,
    cantidad numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad
    FROM ta_15_periodos
    WHERE control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;