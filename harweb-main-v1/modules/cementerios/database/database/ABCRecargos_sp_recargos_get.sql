-- Stored Procedure: sp_recargos_get
-- Tipo: Catalog
-- Descripción: Obtiene un registro de recargo por año y mes.
-- Generado para formulario: ABCRecargos
-- Fecha: 2025-08-28 17:38:53

CREATE OR REPLACE FUNCTION sp_recargos_get(p_axo integer, p_mes integer)
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
    WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;