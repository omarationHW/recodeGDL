-- Stored Procedure: sp_solicnooficial_cancel
-- Tipo: CRUD
-- Descripción: Cancela una solicitud de número oficial (marca como 'C').
-- Generado para formulario: constanciaNoOficialfrm
-- Fecha: 2025-08-27 17:19:01

CREATE OR REPLACE FUNCTION sp_solicnooficial_cancel(
    p_axo INT,
    p_folio INT
) RETURNS TABLE(axo INT, folio INT, vigente VARCHAR) AS $$
BEGIN
    UPDATE solicnooficial
    SET vigente = 'C'
    WHERE axo = p_axo AND folio = p_folio
    RETURNING axo, folio, vigente;
END;
$$ LANGUAGE plpgsql;