-- Stored Procedure: sp_get_periodos_apremio
-- Tipo: Catalog
-- Descripción: Obtiene los periodos requeridos para un apremio dado su id_control.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-27 22:46:46

CREATE OR REPLACE FUNCTION sp_get_periodos_apremio(p_id_control integer)
RETURNS TABLE (
    ayo integer,
    periodo integer,
    importe numeric,
    recargos numeric,
    cantidad integer,
    tipo varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ayo, periodo, importe, recargos, cantidad, tipo
    FROM ta_15_periodos
    WHERE control_otr = p_id_control;
END;
$$ LANGUAGE plpgsql;