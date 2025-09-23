-- Stored Procedure: sp_sol_sdosfavor_list
-- Tipo: Report
-- Descripción: Lista solicitudes de saldo a favor por status
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_list(
    p_status TEXT DEFAULT NULL
) RETURNS TABLE(
    id_solic INTEGER, folio INTEGER, axofol INTEGER, cvecuenta INTEGER, ncompleto TEXT, domp TEXT, extp TEXT, intp TEXT, colp TEXT, telefono TEXT, codp TEXT, solicitante TEXT, observaciones TEXT, doctos TEXT, status TEXT, inconf INTEGER, peticionario INTEGER, feccap TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id_solic, s.folio, s.axofol, s.cvecuenta, c.ncompleto, s.domp, s.extp, s.intp, s.colp, s.telefono, s.codp, s.solicitante, s.observaciones, s.doctos, s.status, s.inconf, s.peticionario, s.feccap
    FROM sol_sdosfavor s
    LEFT JOIN contribuyentes c ON c.cvecuenta = s.cvecuenta
    WHERE (p_status IS NULL OR s.status = p_status)
    ORDER BY s.folio ASC;
END;
$$ LANGUAGE plpgsql;