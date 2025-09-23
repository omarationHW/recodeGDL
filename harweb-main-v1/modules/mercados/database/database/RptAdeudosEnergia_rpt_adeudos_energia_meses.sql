-- Stored Procedure: rpt_adeudos_energia_meses
-- Tipo: Report
-- Descripción: Obtiene los periodos (meses/bimestres) y el importe de adeudo para un id_energia y año específico.
-- Generado para formulario: RptAdeudosEnergia
-- Fecha: 2025-08-27 00:41:19

CREATE OR REPLACE FUNCTION rpt_adeudos_energia_meses(p_id_energia integer, p_axo smallint)
RETURNS TABLE (
    id_energia integer,
    axo smallint,
    periodo smallint,
    importe numeric(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_energia, axo, periodo, importe
    FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo
    ORDER BY id_energia ASC, axo ASC, periodo ASC;
END;
$$ LANGUAGE plpgsql;