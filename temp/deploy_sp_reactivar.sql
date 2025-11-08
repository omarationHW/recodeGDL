-- Deploy sp_reactivar_tramite
DROP FUNCTION IF EXISTS comun.sp_reactivar_tramite(INTEGER, TEXT, TEXT);

CREATE OR REPLACE FUNCTION comun.sp_reactivar_tramite(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_tramite INTEGER,
    estatus_anterior CHAR(1),
    estatus_nuevo CHAR(1)
) AS $$
DECLARE
    v_estatus_actual CHAR(1);
    v_motivo_reactivacion TEXT;
BEGIN
    -- Verificar que el trámite existe
    SELECT t.estatus INTO v_estatus_actual
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE,
            'El trámite no existe en el sistema'::TEXT,
            p_id_tramite,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    -- Verificar que el trámite esté cancelado
    IF v_estatus_actual != 'C' THEN
        RETURN QUERY SELECT
            FALSE,
            'Solo se pueden reactivar trámites cancelados. Estado actual: ' || v_estatus_actual::TEXT,
            p_id_tramite,
            v_estatus_actual,
            v_estatus_actual;
        RETURN;
    END IF;

    -- Construir el motivo de reactivación
    v_motivo_reactivacion := 'REACTIVADO POR ' || UPPER(p_usuario) || '.' || chr(13) || chr(10) ||
                             'FECHA: ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI:SS') || chr(13) || chr(10) ||
                             'MOTIVO: ' || p_motivo;

    -- Actualizar el trámite: cambiar estatus a 'T' (Trámite en proceso)
    UPDATE comun.tramites t
    SET
        estatus = 'T',
        observaciones = COALESCE(t.observaciones || chr(13) || chr(10), '') || v_motivo_reactivacion,
        feccap = NOW()
    WHERE t.id_tramite = p_id_tramite;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE,
        'Trámite reactivado exitosamente. Ahora puede continuar con el proceso normal.'::TEXT,
        p_id_tramite,
        'C'::CHAR(1),
        'T'::CHAR(1);
END;
$$ LANGUAGE plpgsql;
