-- Stored Procedure: sp_sol_sdosfavor_cancel
-- Tipo: CRUD
-- Descripción: Cancela una solicitud de saldo a favor
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_cancel(
    p_id_solic INTEGER,
    p_user_id INTEGER
) RETURNS TABLE(id_solic INTEGER, status TEXT, feccap TIMESTAMP) AS $$
BEGIN
    UPDATE sol_sdosfavor SET
        status = 'C',
        feccap = now(),
        capturista = p_user_id
    WHERE id_solic = p_id_solic
    RETURNING id_solic, status, feccap;
END;
$$ LANGUAGE plpgsql;