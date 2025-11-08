-- Stored Procedure: sp_vencimiento_rec
-- Tipo: Catalog
-- Descripción: Obtiene los vencimientos de recargos y descuentos para un mes dado.
-- Generado para formulario: PadronGlobal
-- Fecha: 2025-08-27 00:18:40

CREATE OR REPLACE FUNCTION sp_vencimiento_rec(p_mes integer)
RETURNS TABLE (
    mes smallint,
    fecha_recargos date,
    fecha_descuento date,
    trimestre smallint,
    sabados smallint,
    sabadosacum smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_recargos, fecha_descuento, trimestre, sabados, sabadosacum
    FROM ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;