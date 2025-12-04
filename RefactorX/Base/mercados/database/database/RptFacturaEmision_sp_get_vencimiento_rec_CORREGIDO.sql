-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptFacturaEmision
-- SP: sp_get_vencimiento_rec
-- Base: mercados.public
-- Fecha: 2025-12-03
-- ============================================

DROP FUNCTION IF EXISTS sp_get_vencimiento_rec(integer);

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
    SELECT
        ta_11_fecha_desc.mes,
        ta_11_fecha_desc.fecha_recargos,
        ta_11_fecha_desc.fecha_descuento,
        ta_11_fecha_desc.trimestre,
        ta_11_fecha_desc.sabados,
        ta_11_fecha_desc.sabadosacum
    FROM comun.ta_11_fecha_desc
    WHERE ta_11_fecha_desc.mes = p_mes;
END;
$$ LANGUAGE plpgsql;
