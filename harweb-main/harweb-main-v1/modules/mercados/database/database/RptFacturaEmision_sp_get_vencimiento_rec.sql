-- Stored Procedure: sp_get_vencimiento_rec
-- Tipo: Catalog
-- Descripción: Obtiene los datos de vencimiento de recargos y descuentos para un mes dado.
-- Generado para formulario: RptFacturaEmision
-- Fecha: 2025-08-27 01:04:38

CREATE OR REPLACE FUNCTION sp_get_vencimiento_rec(p_mes integer)
RETURNS TABLE (
    mes integer,
    fecha_recargos date,
    fecha_descuento date,
    trimestre integer,
    sabados integer,
    sabadosacum integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_recargos, fecha_descuento, trimestre, sabados, sabadosacum
    FROM ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;