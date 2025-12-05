-- ================================================================
-- SP: recaudadora_reimpfrm
-- Módulo: multas_reglamentos
-- Descripción: Búsqueda de documentos para reimpresión
-- Parámetros:
--   p_folio: ID del documento a reimprimir
--   p_tipo_documento: Tipo (multa, recibo, requerimiento, acta)
--   p_id_dependencia: Filtro opcional por dependencia
--   p_formato: Formato de impresión (original, copia, duplicado)
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_reimpfrm(INTEGER, TEXT, INTEGER, TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_reimpfrm(
    p_folio INTEGER,
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
    -- Se pueden agregar más tipos según necesidades
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
        WHERE m.id_multa = p_folio
        AND (p_id_dependencia IS NULL OR m.id_dependencia = p_id_dependencia);

    ELSIF v_tipo = 'recibo' THEN
        -- Para futura implementación de recibos
        -- Por ahora retornar vacío
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

COMMENT ON FUNCTION public.recaudadora_reimpfrm(INTEGER, TEXT, INTEGER, TEXT) IS 'Búsqueda de documentos para reimpresión (multas, recibos, requerimientos, actas)';
