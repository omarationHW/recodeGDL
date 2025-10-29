-- Stored Procedure: sp_cancel_constancia
-- Tipo: CRUD
-- Descripción: Cancela una constancia (marca como no vigente y guarda motivo)
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-26 16:07:52

CREATE OR REPLACE FUNCTION sp_cancel_constancia(
    p_axo integer,
    p_folio integer,
    p_motivo varchar,
    p_capturista varchar
) RETURNS boolean AS $$
BEGIN
    UPDATE constancias
    SET vigente = 'C',
        observacion = p_motivo,
        feccap = CURRENT_DATE,
        capturista = p_capturista
    WHERE axo = p_axo AND folio = p_folio;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;