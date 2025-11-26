-- ================================================================
-- SP: recaudadora_bloqueo_multa
-- Módulo: multas_reglamentos
-- Descripción: Lista requerimientos de multas por folio/cuenta y ejercicio
--              Incluye información de bloqueo para permitir bloquear/desbloquear
-- Tablas: reqmultas, multas
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS recaudadora_bloqueo_multa(VARCHAR, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION recaudadora_bloqueo_multa(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    cvereq INTEGER,
    clave_cuenta TEXT,
    folio INTEGER,
    ejercicio SMALLINT,
    estatus TEXT,
    bloqueado BOOLEAN,
    id_multa INTEGER,
    fecha_emision DATE,
    multas NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    vigencia CHARACTER(1),
    recaud SMALLINT,
    observaciones TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si no se proporciona ejercicio, usar el año actual
    IF p_ejercicio IS NULL OR p_ejercicio = 0 THEN
        p_ejercicio := EXTRACT(YEAR FROM CURRENT_DATE);
    END IF;

    -- Retornar requerimientos de multas (incluyendo bloqueados)
    RETURN QUERY
    SELECT
        r.cvereq,
        p_clave_cuenta::TEXT as clave_cuenta,
        r.folioreq as folio,
        r.axoreq as ejercicio,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'
            WHEN r.vigencia = 'B' THEN 'Bloqueado'
            WHEN r.vigencia = 'C' THEN 'Cancelada'
            WHEN r.vigencia = 'P' THEN 'Pagada'
            ELSE 'Desconocido'
        END as estatus,
        (r.vigencia = 'B')::BOOLEAN as bloqueado,
        r.id_multa,
        r.fecemi as fecha_emision,
        r.multas,
        r.gastos,
        r.total,
        r.vigencia,
        r.recaud,
        r.obs as observaciones
    FROM catastro_gdl.reqmultas r
    WHERE 1=1
        AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR CAST(r.folioreq AS VARCHAR) LIKE '%' || p_clave_cuenta || '%')
        AND r.axoreq = p_ejercicio
        AND r.vigencia IN ('V', 'B')  -- Solo mostrar vigentes y bloqueados
    ORDER BY r.folioreq DESC, r.axoreq DESC
    LIMIT p_limit OFFSET p_offset;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar bloqueos de multa: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION recaudadora_bloqueo_multa(VARCHAR, INTEGER, INTEGER, INTEGER)
IS 'Lista requerimientos de multas por folio/cuenta y ejercicio con información de bloqueo';
