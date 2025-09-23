-- Stored Procedure: sp_list_constancias
-- Tipo: Report
-- Descripción: Lista constancias de uso de suelo con filtros opcionales
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-26 16:07:52

CREATE OR REPLACE FUNCTION sp_list_constancias(
    p_axo integer DEFAULT NULL,
    p_folio integer DEFAULT NULL,
    p_id_licencia integer DEFAULT NULL,
    p_feccap_ini date DEFAULT NULL,
    p_feccap_fin date DEFAULT NULL
) RETURNS TABLE(
    axo integer,
    folio integer,
    id_licencia integer,
    solicita varchar,
    partidapago varchar,
    observacion varchar,
    domicilio varchar,
    vigente varchar,
    feccap date,
    capturista varchar,
    tipo smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, tipo
    FROM constancias
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_feccap_ini IS NULL OR feccap >= p_feccap_ini)
      AND (p_feccap_fin IS NULL OR feccap <= p_feccap_fin)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;