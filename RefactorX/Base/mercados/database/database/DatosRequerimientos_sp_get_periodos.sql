-- Stored Procedure: sp_get_periodos
-- Tipo: Catalog
-- Descripción: Obtiene los periodos de un requerimiento por control_otr
-- Generado para formulario: DatosRequerimientos
-- Fecha: 2025-08-26 23:47:56

DROP FUNCTION IF EXISTS sp_get_periodos(integer);

CREATE OR REPLACE FUNCTION sp_get_periodos(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo integer,
    importe numeric(16,2),
    recargos numeric(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.control_otr, a.ayo, a.periodo, a.importe, a.recargos
    FROM publico.ta_15_periodos a
    WHERE a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;