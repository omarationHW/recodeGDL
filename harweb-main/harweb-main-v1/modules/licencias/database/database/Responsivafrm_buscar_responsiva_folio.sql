-- Stored Procedure: buscar_responsiva_folio
-- Tipo: Catalog
-- Descripción: Busca responsiva por año y folio y tipo.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-27 19:29:54

CREATE OR REPLACE FUNCTION buscar_responsiva_folio(
    p_axo INTEGER,
    p_folio INTEGER,
    p_tipo TEXT
) RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE r.axo = p_axo AND r.folio = p_folio AND r.tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;