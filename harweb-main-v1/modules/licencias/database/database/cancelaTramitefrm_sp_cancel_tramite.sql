-- Stored Procedure: sp_cancel_tramite
-- Tipo: CRUD
-- Descripción: Cancela un trámite si su estatus lo permite y almacena el motivo.
-- Generado para formulario: cancelaTramitefrm
-- Fecha: 2025-08-27 16:33:29

CREATE OR REPLACE FUNCTION sp_cancel_tramite(p_id_tramite INTEGER, p_motivo TEXT)
RETURNS TABLE (
    result TEXT,
    new_status VARCHAR(1)
) AS $$
DECLARE
    v_estatus VARCHAR(1);
    v_motivo TEXT;
BEGIN
    SELECT estatus INTO v_estatus FROM tramites WHERE id_tramite = p_id_tramite;
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT 'Trámite no encontrado'::TEXT, NULL::VARCHAR;
        RETURN;
    END IF;
    IF v_estatus = 'C' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra cancelado'::TEXT, v_estatus;
        RETURN;
    END IF;
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra aprobado. No se puede cancelar.'::TEXT, v_estatus;
        RETURN;
    END IF;
    v_motivo := 'CANCELADO POR PADRON Y LICENCIAS.' || chr(13) || chr(10) || p_motivo;
    UPDATE tramites SET estatus = 'C', espubic = v_motivo WHERE id_tramite = p_id_tramite;
    RETURN QUERY SELECT 'Trámite cancelado exitosamente'::TEXT, 'C'::VARCHAR;
END;
$$ LANGUAGE plpgsql;