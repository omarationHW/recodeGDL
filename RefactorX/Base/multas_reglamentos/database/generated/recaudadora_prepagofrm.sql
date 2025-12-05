-- ================================================================
-- SP: recaudadora_prepagofrm
-- Módulo: multas_reglamentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-04
-- Descripción: Consulta de pagos (prepagos) con filtros flexibles
-- ================================================================

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_prepagofrm(
    p_busqueda VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvepago INTEGER,
    cvecuenta INTEGER,
    recaudadora SMALLINT,
    caja VARCHAR,
    folio INTEGER,
    fecha_pago DATE,
    importe NUMERIC,
    cajero VARCHAR,
    cancelado VARCHAR,
    concepto INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cuenta INTEGER;
    v_folio INTEGER;
    v_cvepago INTEGER;
BEGIN
    -- Si no hay parámetro de búsqueda, no retornar nada
    IF p_busqueda IS NULL OR TRIM(p_busqueda) = '' THEN
        RETURN;
    END IF;

    -- Intentar convertir la búsqueda a número para detectar tipo
    BEGIN
        v_cuenta := p_busqueda::INTEGER;
        v_folio := p_busqueda::INTEGER;
        v_cvepago := p_busqueda::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        v_cuenta := NULL;
        v_folio := NULL;
        v_cvepago := NULL;
    END;

    -- Retornar pagos según el criterio de búsqueda
    RETURN QUERY
    SELECT
        p.cvepago,
        p.cvecuenta,
        p.recaud AS recaudadora,
        TRIM(p.caja)::VARCHAR AS caja,
        p.folio,
        p.fecha AS fecha_pago,
        p.importe,
        TRIM(p.cajero)::VARCHAR AS cajero,
        CASE
            WHEN p.cvecanc IS NULL THEN 'No'
            ELSE 'Sí'
        END::VARCHAR AS cancelado,
        p.cveconcepto AS concepto
    FROM catastro_gdl.pagos p
    WHERE
        (v_cuenta IS NOT NULL AND p.cvecuenta = v_cuenta)
        OR (v_folio IS NOT NULL AND p.folio = v_folio)
        OR (v_cvepago IS NOT NULL AND p.cvepago = v_cvepago)
    ORDER BY p.fecha DESC, p.cvepago DESC
    LIMIT 100; -- Límite de seguridad

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_prepagofrm(VARCHAR) IS
'Consulta de pagos (prepagos) con filtros flexibles. Busca por cuenta, folio o clave de pago. Parámetro: p_busqueda (número de cuenta, folio o clave de pago)';
