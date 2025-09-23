-- Stored Procedure: sp_sol_sdosfavor_create
-- Tipo: CRUD
-- Descripción: Crea una nueva solicitud de saldo a favor
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_create(
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
DECLARE
    v_folio INTEGER;
    v_axofol INTEGER;
BEGIN
    -- Obtener folio y año actual
    SELECT nextval('sol_sdosfavor_folio_seq') INTO v_folio;
    v_axofol := EXTRACT(YEAR FROM CURRENT_DATE);
    INSERT INTO sol_sdosfavor (
        folio, axofol, cvecuenta, domp, extp, intp, colp, telefono, codp, solicitante, observaciones, doctos, status, inconf, peticionario, feccap, capturista
    ) VALUES (
        v_folio, v_axofol, p_cvecuenta, p_domp, p_extp, p_intp, p_colp, p_telefono, p_codp, p_solicitante, p_observaciones, p_doctos, p_status, p_inconf, p_peticionario, p_feccap, p_user_id
    ) RETURNING id_solic, folio, axofol, feccap INTO id_solic, folio, axofol, feccap;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;