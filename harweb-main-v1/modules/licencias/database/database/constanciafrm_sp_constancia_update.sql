-- Stored Procedure: sp_constancia_update
-- Tipo: CRUD
-- Descripción: Actualiza los campos editables de una constancia.
-- Generado para formulario: constanciafrm
-- Fecha: 2025-08-26 15:37:55

CREATE OR REPLACE FUNCTION sp_constancia_update(
    p_axo integer,
    p_folio integer,
    p_observacion varchar default null,
    p_partidapago varchar default null,
    p_domicilio varchar default null,
    p_solicita varchar default null
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    UPDATE constancias SET
        observacion = COALESCE(p_observacion, observacion),
        partidapago = COALESCE(p_partidapago, partidapago),
        domicilio = COALESCE(p_domicilio, domicilio),
        solicita = COALESCE(p_solicita, solicita)
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT * FROM constancias WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;