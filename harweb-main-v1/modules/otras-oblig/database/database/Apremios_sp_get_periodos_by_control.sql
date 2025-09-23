-- Stored Procedure: sp_get_periodos_by_control
-- Tipo: Catalog
-- Descripción: Obtiene los periodos requeridos para un control de apremio.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-28 12:35:37

CREATE OR REPLACE FUNCTION sp_get_periodos_by_control(id_control integer)
RETURNS TABLE (
    ayo integer,
    periodo integer,
    importe numeric(15,2),
    recargos numeric(15,2),
    cantidad integer,
    tipo varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ayo, periodo, importe, recargos, cantidad, tipo
    FROM ta_15_periodos
    WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;