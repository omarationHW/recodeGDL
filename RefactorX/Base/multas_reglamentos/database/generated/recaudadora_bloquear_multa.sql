-- ================================================================
-- SP: recaudadora_bloquear_multa
-- Módulo: multas_reglamentos
-- Descripción: Bloquea un requerimiento de multa cambiando su vigencia a 'B'
--              y registra la acción en el histórico de observaciones
-- Tablas: reqmultas, reqmulta_obs_hist
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS recaudadora_bloquear_multa(INTEGER, TEXT, TEXT);

CREATE OR REPLACE FUNCTION recaudadora_bloquear_multa(
    p_cvereq INTEGER,
    p_motivo TEXT,
    p_capturista TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    cvereq INTEGER,
    vigencia_anterior TEXT,
    vigencia_nueva TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vigencia_actual CHARACTER(1);
    v_folioreq INTEGER;
    v_axoreq SMALLINT;
BEGIN
    -- Validar parámetros
    IF p_cvereq IS NULL OR p_cvereq = 0 THEN
        RETURN QUERY SELECT FALSE, 'El cvereq es requerido'::TEXT, NULL::INTEGER, NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo del bloqueo es requerido'::TEXT, p_cvereq, NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RETURN QUERY SELECT FALSE, 'El capturista es requerido'::TEXT, p_cvereq, NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    -- Verificar que el requerimiento existe
    SELECT r.vigencia, r.folioreq, r.axoreq
    INTO v_vigencia_actual, v_folioreq, v_axoreq
    FROM catastro_gdl.reqmultas r
    WHERE r.cvereq = p_cvereq;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'El requerimiento no existe'::TEXT, p_cvereq, NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    -- Verificar que no esté ya bloqueado
    IF v_vigencia_actual = 'B' THEN
        RETURN QUERY SELECT FALSE, 'El requerimiento ya está bloqueado'::TEXT, p_cvereq, v_vigencia_actual::TEXT, v_vigencia_actual::TEXT;
        RETURN;
    END IF;

    -- Verificar que esté vigente
    IF v_vigencia_actual != 'V' THEN
        RETURN QUERY SELECT FALSE,
            'Solo se pueden bloquear requerimientos vigentes (V). Estado actual: ' || v_vigencia_actual::TEXT,
            p_cvereq,
            v_vigencia_actual::TEXT,
            v_vigencia_actual::TEXT;
        RETURN;
    END IF;

    -- Bloquear el requerimiento
    UPDATE catastro_gdl.reqmultas
    SET vigencia = 'B',
        obs = COALESCE(obs || ' | ', '') || 'BLOQUEADO: ' || p_motivo
    WHERE reqmultas.cvereq = p_cvereq;

    -- Registrar en histórico de observaciones
    INSERT INTO catastro_gdl.reqmulta_obs_hist (
        cvereq,
        fecha_movimiento,
        observacion,
        capturista
    ) VALUES (
        p_cvereq,
        CURRENT_DATE,
        'BLOQUEO DE MULTA - Folio: ' || v_folioreq || '/' || v_axoreq || ' - Motivo: ' || p_motivo,
        LEFT(p_capturista, 10)
    );

    -- Retornar éxito
    RETURN QUERY SELECT TRUE,
        'Requerimiento bloqueado exitosamente'::TEXT,
        p_cvereq,
        v_vigencia_actual::TEXT,
        'B'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            'Error al bloquear requerimiento: ' || SQLERRM,
            p_cvereq,
            NULL::TEXT,
            NULL::TEXT;
END;
$$;

COMMENT ON FUNCTION recaudadora_bloquear_multa(INTEGER, TEXT, TEXT)
IS 'Bloquea un requerimiento de multa cambiando su vigencia a ''B'' y registra en histórico';
