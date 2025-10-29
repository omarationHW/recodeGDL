-- Stored Procedure: sp_trasp_400_by_anio_folio
-- Tipo: Report
-- Descripción: Obtiene los registros de trasp_400 filtrando por tafol (año) y tfol (folio).
-- Generado para formulario: ConsPag400
-- Fecha: 2025-08-26 23:38:10

CREATE OR REPLACE FUNCTION sp_trasp_400_by_anio_folio(
    p_anio integer,
    p_folio integer
)
RETURNS TABLE (
    tafol smallint,
    tfol integer,
    rect smallint,
    urt smallint,
    ctat integer,
    tncta smallint,
    tfepag integer,
    topag smallint,
    tcpag varchar,
    toppag integer,
    tlug varchar,
    tspag smallint,
    tdsdpag smallint,
    thstpag smallint,
    timpto float,
    tflag1 smallint,
    tflag2 smallint,
    tcapto varchar,
    tfecha integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM trasp_400
    WHERE tafol = p_anio AND tfol = p_folio;
END;
$$ LANGUAGE plpgsql;