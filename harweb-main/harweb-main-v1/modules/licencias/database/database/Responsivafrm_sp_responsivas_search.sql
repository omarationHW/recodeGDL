-- Stored Procedure: sp_responsivas_search
-- Tipo: Report
-- Descripción: Busca responsivas por filtros.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-26 18:03:33

CREATE OR REPLACE FUNCTION sp_responsivas_search(tipo_in TEXT, axo_in INTEGER, folio_in INTEGER, licencia_in TEXT)
RETURNS TABLE(axo INTEGER, folio INTEGER, id_licencia INTEGER, tipo TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT) AS $$
DECLARE
    lic_id INTEGER;
    sql TEXT;
BEGIN
    sql := 'SELECT axo, folio, id_licencia, tipo, observacion, vigente, feccap, capturista FROM responsivas WHERE tipo = $1';
    IF axo_in IS NOT NULL THEN
        sql := sql || ' AND axo = ' || axo_in;
    END IF;
    IF folio_in IS NOT NULL THEN
        sql := sql || ' AND folio = ' || folio_in;
    END IF;
    IF licencia_in IS NOT NULL THEN
        SELECT id_licencia INTO lic_id FROM licencias WHERE licencia = licencia_in;
        IF lic_id IS NOT NULL THEN
            sql := sql || ' AND id_licencia = ' || lic_id;
        END IF;
    END IF;
    sql := sql || ' ORDER BY axo DESC, folio DESC';
    RETURN QUERY EXECUTE sql USING tipo_in;
END;
$$ LANGUAGE plpgsql;