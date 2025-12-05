-- ================================================================
-- SP: recaudadora_reimpfrm (versión con múltiples resultados)
-- Módulo: multas_reglamentos
-- Descripción: Búsqueda de documentos para reimpresión
-- Si p_folio es NULL o 0, devuelve múltiples documentos filtrados
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_reimpfrm(INTEGER, TEXT, INTEGER, TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_reimpfrm(
    p_folio INTEGER DEFAULT NULL,
    p_tipo_documento TEXT DEFAULT 'multa',
    p_id_dependencia INTEGER DEFAULT NULL,
    p_formato TEXT DEFAULT 'original'
)
RETURNS TABLE (
    folio INTEGER,
    tipo_documento TEXT,
    fecha DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    importe NUMERIC,
    estatus TEXT,
    dependencia SMALLINT,
    axo_acta SMALLINT,
    num_acta INTEGER,
    calificacion NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    id_ley SMALLINT,
    id_infraccion SMALLINT,
    formato_impresion TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo TEXT;
BEGIN
    v_tipo := LOWER(TRIM(COALESCE(p_tipo_documento, 'multa')));

    -- Por ahora solo implementamos búsqueda de multas
    IF v_tipo = 'multa' THEN
        RETURN QUERY
        SELECT
            m.id_multa AS folio,
            'multa'::TEXT AS tipo_documento,
            m.fecha_acta AS fecha,
            m.contribuyente,
            m.domicilio,
            m.total AS importe,
            CASE
                WHEN m.cvepago IS NOT NULL THEN 'PAGADO'
                WHEN m.fecha_cancelacion IS NOT NULL THEN 'CANCELADO'
                ELSE 'PENDIENTE'
            END::TEXT AS estatus,
            m.id_dependencia AS dependencia,
            m.axo_acta,
            m.num_acta,
            m.calificacion,
            m.multa,
            m.gastos,
            m.total,
            m.id_ley,
            m.id_infraccion,
            p_formato::TEXT AS formato_impresion
        FROM comun.multas m
        WHERE (p_folio IS NULL OR p_folio = 0 OR m.id_multa = p_folio)
        AND (p_id_dependencia IS NULL OR m.id_dependencia = p_id_dependencia)
        AND m.contribuyente IS NOT NULL
        ORDER BY m.fecha_acta DESC, m.id_multa DESC
        LIMIT 100;

    ELSIF v_tipo = 'recibo' THEN
        -- Para futura implementación de recibos
        RETURN;

    ELSIF v_tipo = 'requerimiento' THEN
        -- Para futura implementación de requerimientos
        RETURN;

    ELSIF v_tipo = 'acta' THEN
        -- Para futura implementación de actas
        RETURN;

    ELSE
        -- Tipo de documento no reconocido
        RETURN;
    END IF;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_reimpfrm(INTEGER, TEXT, INTEGER, TEXT) IS 'Búsqueda de documentos para reimpresión con soporte para múltiples resultados';
