-- Stored Procedure: sp_update_constancia
-- Tipo: CRUD
-- Descripción: Actualiza una constancia existente
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-26 16:07:52

CREATE OR REPLACE FUNCTION sp_update_constancia(
    p_axo integer,
    p_folio integer,
    p_solicita varchar,
    p_partidapago varchar DEFAULT NULL,
    p_observacion varchar DEFAULT NULL,
    p_domicilio varchar DEFAULT NULL,
    p_capturista varchar
) RETURNS boolean AS $$
BEGIN
    UPDATE constancias
    SET solicita = p_solicita,
        partidapago = p_partidapago,
        observacion = p_observacion,
        domicilio = p_domicilio,
        feccap = CURRENT_DATE,
        capturista = p_capturista
    WHERE axo = p_axo AND folio = p_folio;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;