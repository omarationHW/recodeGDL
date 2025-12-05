-- ================================================================
-- SP: recaudadora_canc
-- Módulo: multas_reglamentos
-- Descripción: Cancelación de multas por folio y ejercicio
-- Tablas: multas, canc_multa_pagada
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_canc(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS comun.recaudadora_canc(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.recaudadora_canc(
    p_folio INTEGER,
    p_ejercicio INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    id_multa INTEGER,
    num_acta INTEGER,
    axo_acta SMALLINT,
    contribuyente VARCHAR,
    total NUMERIC,
    fecha_cancelacion DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_multa INTEGER;
    v_fecha_cancel DATE;
    v_total NUMERIC;
    v_contribuyente VARCHAR;
BEGIN
    -- Buscar la multa por folio y ejercicio
    SELECT
        m.id_multa,
        m.total,
        m.contribuyente,
        m.fecha_cancelacion
    INTO
        v_id_multa,
        v_total,
        v_contribuyente,
        v_fecha_cancel
    FROM catastro_gdl.multas m
    WHERE m.num_acta = p_folio
      AND m.axo_acta = p_ejercicio
    LIMIT 1;

    -- Verificar si existe la multa
    IF v_id_multa IS NULL THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('No se encontró multa con folio ' || p_folio || ' y ejercicio ' || p_ejercicio)::VARCHAR,
            NULL::INTEGER,
            p_folio,
            p_ejercicio::SMALLINT,
            NULL::VARCHAR,
            NULL::NUMERIC,
            NULL::DATE;
        RETURN;
    END IF;

    -- Verificar si ya está cancelada
    IF v_fecha_cancel IS NOT NULL THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('La multa ya se encuentra cancelada desde ' || v_fecha_cancel::TEXT)::VARCHAR,
            v_id_multa,
            p_folio,
            p_ejercicio::SMALLINT,
            v_contribuyente,
            v_total,
            v_fecha_cancel;
        RETURN;
    END IF;

    -- Cancelar la multa
    UPDATE catastro_gdl.multas m
    SET fecha_cancelacion = CURRENT_DATE,
        user_baja = 'SISTEMA',
        observacion = COALESCE(m.observacion, '') || ' | Cancelada el ' || CURRENT_DATE::TEXT
    WHERE m.id_multa = v_id_multa;

    -- Registrar en tabla de cancelaciones para auditoría (si la tabla existe)
    BEGIN
        INSERT INTO catastro_gdl.canc_multa_pagada (
            id_multa,
            observacion,
            vigencia,
            fecha_alta,
            usuario_alta
        ) VALUES (
            v_id_multa,
            'Cancelación de multa folio ' || p_folio::TEXT || ' ejercicio ' || p_ejercicio::TEXT,
            'V',
            CURRENT_TIMESTAMP,
            'SISTEMA'
        );
    EXCEPTION
        WHEN OTHERS THEN
            -- Si falla el insert en auditoría, continuar de todas formas
            NULL;
    END;

    -- Retornar resultado exitoso
    RETURN QUERY
    SELECT
        TRUE,
        'Multa cancelada exitosamente'::VARCHAR,
        v_id_multa,
        p_folio,
        p_ejercicio::SMALLINT,
        v_contribuyente,
        v_total,
        CURRENT_DATE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al cancelar multa: ' || SQLERRM)::VARCHAR,
            NULL::INTEGER,
            p_folio,
            p_ejercicio::SMALLINT,
            NULL::VARCHAR,
            NULL::NUMERIC,
            NULL::DATE;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_canc(INTEGER, INTEGER)
IS 'Cancela una multa por folio (num_acta) y ejercicio (axo_acta)';
