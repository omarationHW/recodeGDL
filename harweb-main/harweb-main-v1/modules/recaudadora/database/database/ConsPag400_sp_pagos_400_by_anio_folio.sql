-- Stored Procedure: sp_pagos_400_by_anio_folio
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos_400 para recaud = 0, urbrus = 9, cuenta = 0 (por comprobante, usando año y folio).
-- Generado para formulario: ConsPag400
-- Fecha: 2025-08-26 23:38:10

CREATE OR REPLACE FUNCTION sp_pagos_400_by_anio_folio(
    p_anio integer,
    p_folio integer
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
    WHERE recaud = 0 AND urbrus = 9 AND cuenta = 0;
END;
$$ LANGUAGE plpgsql;