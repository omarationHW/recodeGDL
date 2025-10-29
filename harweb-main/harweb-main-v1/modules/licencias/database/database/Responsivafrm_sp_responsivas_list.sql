-- Stored Procedure: sp_responsivas_list
-- Tipo: Report
-- Descripción: Lista responsivas por tipo.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-26 18:03:33

CREATE OR REPLACE FUNCTION sp_responsivas_list(tipo_in TEXT)
RETURNS TABLE(axo INTEGER, folio INTEGER, id_licencia INTEGER, tipo TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT) AS $$
BEGIN
    RETURN QUERY SELECT axo, folio, id_licencia, tipo, observacion, vigente, feccap, capturista FROM responsivas WHERE tipo = tipo_in ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;