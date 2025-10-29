-- Stored Procedure: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un mes, ordenados por año.
-- Generado para formulario: ABCRecargos
-- Fecha: 2025-08-28 17:38:53

CREATE OR REPLACE FUNCTION sp_recargos_list(p_mes integer)
RETURNS TABLE(
    axo integer,
    mes smallint,
    porcentaje_parcial float,
    porcentaje_global float,
    usuario integer,
    fecha_mov date
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, mes, porcentaje_parcial, porcentaje_global, usuario, fecha_mov
    FROM ta_13_recargosrcm
    WHERE mes = p_mes
    ORDER BY axo;
END;
$$ LANGUAGE plpgsql;