-- Stored Procedure: sp_get_periodos_by_requerimiento
-- Tipo: Catalog
-- Descripción: Obtiene los periodos asociados a un requerimiento
-- Generado para formulario: ConsRequerimientos
-- Fecha: 2025-08-26 23:23:01

CREATE OR REPLACE FUNCTION sp_get_periodos_by_requerimiento(
    p_control_otr integer
)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, control_otr, ayo, periodo, importe, recargos
    FROM ta_15_periodos
    WHERE control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;