-- Stored Procedure: cancelar_responsiva
-- Tipo: CRUD
-- Descripción: Cancela una responsiva/supervisión por axo y folio, guardando el motivo.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-27 19:29:54

CREATE OR REPLACE FUNCTION cancelar_responsiva(
    p_axo INTEGER,
    p_folio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS TABLE (axo INTEGER, folio INTEGER, vigente TEXT, observacion TEXT) AS $$
BEGIN
    UPDATE responsivas
    SET vigente = 'C', observacion = p_motivo, capturista = p_usuario
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT p_axo, p_folio, 'C', p_motivo;
END;
$$ LANGUAGE plpgsql;