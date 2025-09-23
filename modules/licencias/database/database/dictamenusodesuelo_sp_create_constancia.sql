-- Stored Procedure: sp_create_constancia
-- Tipo: CRUD
-- Descripción: Crea una nueva constancia de uso de suelo y retorna axo y folio
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-26 16:07:52

CREATE OR REPLACE FUNCTION sp_create_constancia(
    p_tipo smallint,
    p_solicita varchar,
    p_partidapago varchar DEFAULT NULL,
    p_observacion varchar DEFAULT NULL,
    p_domicilio varchar DEFAULT NULL,
    p_id_licencia integer DEFAULT NULL,
    p_capturista varchar
) RETURNS TABLE(axo integer, folio integer) AS $$
DECLARE
    v_folio integer;
    v_axo integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    SELECT nextval('constancias_folio_seq') INTO v_folio;
    INSERT INTO constancias(axo, folio, tipo, solicita, partidapago, observacion, domicilio, id_licencia, vigente, feccap, capturista)
    VALUES (v_axo, v_folio, p_tipo, p_solicita, p_partidapago, p_observacion, p_domicilio, p_id_licencia, 'V', CURRENT_DATE, p_capturista);
    RETURN QUERY SELECT v_axo, v_folio;
END;
$$ LANGUAGE plpgsql;