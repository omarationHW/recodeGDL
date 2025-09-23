-- Stored Procedure: sp_conspag400
-- Tipo: Report
-- Descripción: Consulta pagos del AS400 filtrando por recaud, urbrus y cuenta.
-- Generado para formulario: conspag400
-- Fecha: 2025-08-27 16:03:57

CREATE OR REPLACE FUNCTION sp_conspag400(
    p_recaud integer,
    p_urbrus integer,
    p_cuenta integer
)
RETURNS TABLE (
    axopag smallint,
    mespag smallint,
    diapag smallint,
    ofnpag smallint,
    cajpag varchar(1),
    opepag integer,
    tpopag varchar(1),
    secpag smallint,
    recaud smallint,
    urbrus smallint,
    cuenta integer,
    mupio smallint,
    dsdpag smallint,
    hstpag smallint,
    impto double precision,
    flag smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        axopag, mespag, diapag, ofnpag, cajpag, opepag, tpopag, secpag, recaud, urbrus, cuenta, mupio, dsdpag, hstpag, impto, flag
    FROM pagos_400
    WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;
