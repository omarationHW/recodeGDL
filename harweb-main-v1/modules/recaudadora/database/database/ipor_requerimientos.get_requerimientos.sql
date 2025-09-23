-- Stored Procedure: requerimientos.get_requerimientos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos de predial según parámetros de año, recaudadora y rango de folios.
-- Generado para formulario: ipor
-- Fecha: 2025-08-27 12:29:04

CREATE OR REPLACE FUNCTION requerimientos.get_requerimientos(axoreq integer, recaud integer, folioini integer, foliofin integer)
RETURNS TABLE(
    cvereq integer,
    cveejecut integer,
    folioreq integer,
    axoreq integer,
    cvecuenta integer,
    recaud integer,
    cvepago integer,
    impuesto numeric,
    recargos numeric,
    gastos numeric,
    multas numeric,
    total numeric,
    gasto_req numeric,
    fecemi date,
    fecent date,
    cvecancr varchar,
    axoini integer,
    bimini integer,
    axofin integer,
    bimfin integer,
    secuencia integer,
    vigencia varchar,
    feccap date,
    capturista varchar,
    fecejec date,
    feccit date,
    horacit varchar,
    horaprac varchar,
    recibereq varchar,
    recibecit varchar,
    obs text,
    feccan date,
    nodiligenciado varchar,
    zona_subzona varchar,
    impreso varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM reqpredial
    WHERE axoreq = $1 AND recaud = $2 AND folioreq BETWEEN $3 AND $4;
END;
$$ LANGUAGE plpgsql;