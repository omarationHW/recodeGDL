-- Stored Procedure: sp_get_apremios_periodos
-- Tipo: Catalog
-- Descripción: Obtiene los periodos requeridos para un id_control de apremios.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-27 13:36:07

CREATE OR REPLACE FUNCTION sp_get_apremios_periodos(id_control integer)
RETURNS TABLE(
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
    WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;