-- Stored Procedure: sp_get_meses_adeudo_1998
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo para un local en 1998.
-- Generado para formulario: RptAdeudosAbastos1998
-- Fecha: 2025-08-27 00:37:50

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo_1998(p_vid_local integer, p_vaxo integer)
RETURNS TABLE(
    id_local integer,
    axo smallint,
    periodo smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe
    FROM ta_11_adeudo_local
    WHERE id_local = p_vid_local AND axo = p_vaxo
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;