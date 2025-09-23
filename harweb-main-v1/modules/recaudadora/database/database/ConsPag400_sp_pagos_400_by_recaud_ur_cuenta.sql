-- Stored Procedure: sp_pagos_400_by_recaud_ur_cuenta
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos_400 filtrando por recaud, urbrus y cuenta.
-- Generado para formulario: ConsPag400
-- Fecha: 2025-08-26 23:38:10

CREATE OR REPLACE FUNCTION sp_pagos_400_by_recaud_ur_cuenta(
    p_recaud integer,
    p_ur integer,
    p_cuenta integer
)
RETURNS TABLE (
    axopag smallint,
    mespag smallint,
    diapag smallint,
    ofnpag smallint,
    cajpag varchar,
    opepag integer,
    tpopag varchar,
    secpag smallint,
    recaud smallint,
    urbrus smallint,
    cuenta integer,
    mupio smallint,
    dsdpag smallint,
    hstpag smallint,
    impto float,
    flag smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pagos_400
    WHERE recaud = p_recaud AND urbrus = p_ur AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;