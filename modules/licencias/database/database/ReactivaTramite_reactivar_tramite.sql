-- Stored Procedure: reactivar_tramite
-- Tipo: CRUD
-- Descripción: Reactivar un trámite cancelado o rechazado, actualizando estatus y revisiones.
-- Generado para formulario: ReactivaTramite
-- Fecha: 2025-08-27 19:03:47

CREATE OR REPLACE FUNCTION reactivar_tramite(p_id_tramite integer, p_motivo text)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_estatus varchar;
    v_motivo text;
    v_count integer;
BEGIN
    SELECT estatus INTO v_estatus FROM tramites WHERE id_tramite = p_id_tramite;
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT false, 'Trámite no encontrado.';
        RETURN;
    END IF;
    IF v_estatus NOT IN ('C', 'R') THEN
        RETURN QUERY SELECT false, 'El trámite no se encuentra cancelado o rechazado.';
        RETURN;
    END IF;
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT false, 'El trámite ya se encuentra aprobado. No se puede reactivar.';
        RETURN;
    END IF;
    v_motivo := 'REACTIVADO POR PADRON Y LICENCIAS.\n' || p_motivo;
    -- Actualizar tramite
    UPDATE tramites SET estatus = 'T', espubic = v_motivo WHERE id_tramite = p_id_tramite;
    -- Reactivar revisiones
    UPDATE revisiones SET estatus = 'V'
    WHERE id_tramite = p_id_tramite AND estatus IN ('C', 'N');
    -- Reactivar seg_revision
    UPDATE seg_revision SET estatus = 'V', observacion = v_motivo
    WHERE id_revision IN (
        SELECT id_revision FROM revisiones WHERE id_tramite = p_id_tramite AND estatus = 'V'
    );
    RETURN QUERY SELECT true, 'Trámite reactivado correctamente.';
END;
$$ LANGUAGE plpgsql;