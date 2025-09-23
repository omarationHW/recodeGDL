-- Stored Procedure: buscar_responsiva_licencia
-- Tipo: Catalog
-- Descripción: Busca responsivas por número de licencia y tipo.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-27 19:29:54

CREATE OR REPLACE FUNCTION buscar_responsiva_licencia(
    p_licencia INTEGER,
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
    WHERE l.licencia = p_licencia AND r.tipo = p_tipo
    ORDER BY r.axo DESC, r.folio DESC;
END;
$$ LANGUAGE plpgsql;