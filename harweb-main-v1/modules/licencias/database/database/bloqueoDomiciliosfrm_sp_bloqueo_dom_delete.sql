-- Stored Procedure: sp_bloqueo_dom_delete
-- Tipo: CRUD
-- Descripción: Elimina (cancela) un domicilio bloqueado y guarda histórico.
-- Generado para formulario: bloqueoDomiciliosfrm
-- Fecha: 2025-08-26 14:44:52

CREATE OR REPLACE FUNCTION sp_bloqueo_dom_delete(
    p_folio INTEGER,
    p_motivo VARCHAR,
    p_usuario VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM bloqueo_dom WHERE folio = p_folio;
    IF v_row IS NULL THEN
        RETURN FALSE;
    END IF;
    -- Guarda histórico
    INSERT INTO h_bloqueo_dom SELECT *, NOW(), p_motivo, 'ED', p_usuario FROM bloqueo_dom WHERE folio = p_folio;
    DELETE FROM bloqueo_dom WHERE folio = p_folio;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;