-- Stored Procedure: sp_constancia_create
-- Tipo: CRUD
-- Descripción: Crea una nueva constancia, actualiza el folio en parametros y retorna el registro insertado.
-- Generado para formulario: constanciafrm
-- Fecha: 2025-08-26 15:37:55

CREATE OR REPLACE FUNCTION sp_constancia_create(
    p_tipo smallint,
    p_solicita varchar,
    p_partidapago varchar default null,
    p_observacion varchar default null,
    p_domicilio varchar default null,
    p_id_licencia integer default null,
    p_capturista varchar
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
DECLARE
    v_folio integer;
    v_axo integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    SELECT constancia INTO v_folio FROM parametros ORDER BY id DESC LIMIT 1;
    v_folio := COALESCE(v_folio, 0) + 1;
    UPDATE parametros SET constancia = v_folio;
    INSERT INTO constancias(axo, folio, tipo, solicita, partidapago, observacion, domicilio, id_licencia, vigente, feccap, capturista)
    VALUES (v_axo, v_folio, p_tipo, p_solicita, p_partidapago, p_observacion, p_domicilio, p_id_licencia, 'V', CURRENT_DATE, p_capturista);
    RETURN QUERY SELECT * FROM constancias WHERE axo = v_axo AND folio = v_folio;
END;
$$ LANGUAGE plpgsql;