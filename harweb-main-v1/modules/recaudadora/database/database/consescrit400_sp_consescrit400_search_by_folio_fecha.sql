-- Stored Procedure: sp_consescrit400_search_by_folio_fecha
-- Tipo: Report
-- Descripción: Busca registros en escrituras_400 por folio y fecha.
-- Generado para formulario: consescrit400
-- Fecha: 2025-08-26 23:25:11

CREATE OR REPLACE FUNCTION sp_consescrit400_search_by_folio_fecha(p_folio integer, p_fecha integer)
RETURNS TABLE (
    escritura integer,
    notario smallint,
    mpio smallint,
    folio integer,
    axofolio smallint,
    cuenta integer,
    recaud smallint,
    nocomp integer,
    axocomp smallint,
    ccta integer,
    crec smallint,
    clave varchar(13),
    capturista varchar(8),
    enviado varchar(12),
    regresado varchar(12),
    fecha integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM escrituras_400
    WHERE folio = p_folio AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;