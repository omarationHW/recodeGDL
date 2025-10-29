-- Stored Procedure: sp_sol_sdosfavor_update
-- Tipo: CRUD
-- Descripción: Actualiza una solicitud de saldo a favor existente
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_update(
    p_id_solic INTEGER,
    p_cvecuenta INTEGER,
    p_domp TEXT,
    p_extp TEXT,
    p_intp TEXT,
    p_colp TEXT,
    p_telefono TEXT,
    p_codp TEXT,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_doctos TEXT,
    p_status TEXT,
    p_inconf INTEGER,
    p_peticionario INTEGER,
    p_user_id INTEGER,
    p_feccap TIMESTAMP
) RETURNS TABLE(id_solic INTEGER, folio INTEGER, axofol INTEGER, feccap TIMESTAMP) AS $$
BEGIN
    UPDATE sol_sdosfavor SET
        cvecuenta = p_cvecuenta,
        domp = p_domp,
        extp = p_extp,
        intp = p_intp,
        colp = p_colp,
        telefono = p_telefono,
        codp = p_codp,
        solicitante = p_solicitante,
        observaciones = p_observaciones,
        doctos = p_doctos,
        status = p_status,
        inconf = p_inconf,
        peticionario = p_peticionario,
        feccap = p_feccap,
        capturista = p_user_id
    WHERE id_solic = p_id_solic
    RETURNING id_solic, folio, axofol, feccap;
END;
$$ LANGUAGE plpgsql;