-- Stored Procedure: sp_constancia_search
-- Tipo: Catalog
-- Descripción: Busca constancias por axo/folio, id_licencia o fecha de captura.
-- Generado para formulario: constanciafrm
-- Fecha: 2025-08-26 15:37:55

CREATE OR REPLACE FUNCTION sp_constancia_search(
    p_axo integer default null,
    p_folio integer default null,
    p_id_licencia integer default null,
    p_feccap date default null
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    RETURN QUERY SELECT * FROM constancias
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_feccap IS NULL OR feccap = p_feccap)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;