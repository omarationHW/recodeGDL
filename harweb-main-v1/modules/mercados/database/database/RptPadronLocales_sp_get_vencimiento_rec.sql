-- Stored Procedure: sp_get_vencimiento_rec
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de vencimiento de recargos y descuentos para un mes.
-- Generado para formulario: RptPadronLocales
-- Fecha: 2025-08-27 01:27:45

CREATE OR REPLACE FUNCTION sp_get_vencimiento_rec(p_mes SMALLINT)
RETURNS TABLE (
    mes SMALLINT,
    fecha_recargos DATE,
    fecha_descuento DATE,
    trimestre SMALLINT,
    sabados SMALLINT,
    sabadosacum SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_recargos, fecha_descuento, trimestre, sabados, sabadosacum
    FROM ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;