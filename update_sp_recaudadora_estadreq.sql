-- Actualización del Stored Procedure para estadreq (estadísticas de requerimientos)
-- Combina datos de múltiples tablas de requerimientos del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_estadreq(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_estadreq(
    q VARCHAR DEFAULT ''
)
RETURNS TABLE (
    ejecutor VARCHAR,
    recaudadora VARCHAR,
    total_requerimientos BIGINT,
    entregados BIGINT,
    pendientes BIGINT,
    vencidos BIGINT,
    cancelados BIGINT,
    monto_total DECIMAL
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH requerimientos_unificados AS (
        -- Requerimientos de multas
        SELECT
            r.cveejecut,
            r.recaud,
            r.vigencia,
            r.cvepago,
            COALESCE(r.total, r.multas) AS monto,
            TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) AS ejecutor_nombre
        FROM publico.reqmultas r
        LEFT JOIN public.ejecutor e ON r.cveejecut = e.cveejecutor
        WHERE r.vigencia IS NOT NULL

        UNION ALL

        -- Requerimientos de licencias
        SELECT
            r.cveejecut,
            r.recaud,
            r.vigencia,
            r.cvepago,
            r.total AS monto,
            TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) AS ejecutor_nombre
        FROM public.reqbflicencias r
        LEFT JOIN public.ejecutor e ON r.cveejecut = e.cveejecutor
        WHERE r.vigencia IS NOT NULL

        UNION ALL

        -- Requerimientos de anuncios
        SELECT
            r.cveejecut,
            r.recaud,
            r.vigencia,
            r.cvepago,
            r.total AS monto,
            TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) AS ejecutor_nombre
        FROM public.reqanuncios r
        LEFT JOIN public.ejecutor e ON r.cveejecut = e.cveejecutor
        WHERE r.vigencia IS NOT NULL

        UNION ALL

        -- Requerimientos prediales BF
        SELECT
            r.cveejecut,
            r.recaud,
            r.vigencia,
            r.cvepago,
            r.total AS monto,
            TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) AS ejecutor_nombre
        FROM public.reqbfpredial r
        LEFT JOIN public.ejecutor e ON r.cveejecut = e.cveejecutor
        WHERE r.vigencia IS NOT NULL
    )
    SELECT
        COALESCE(NULLIF(TRIM(ru.ejecutor_nombre), ''), 'SIN EJECUTOR')::VARCHAR AS ejecutor,
        CASE
            WHEN ru.recaud = 1 THEN 'RECAUDACION PREDIAL'
            WHEN ru.recaud = 2 THEN 'RECAUDACION MUNICIPAL'
            WHEN ru.recaud = 3 THEN 'MULTAS'
            WHEN ru.recaud = 4 THEN 'LICENCIAS'
            ELSE 'OTROS'
        END::VARCHAR AS recaudadora,
        COUNT(*)::BIGINT AS total_requerimientos,
        -- Entregados: pagados o ejecutados
        COUNT(CASE
            WHEN ru.cvepago IS NOT NULL AND ru.cvepago > 0 THEN 1
            WHEN ru.vigencia IN ('E', 'F') THEN 1
        END)::BIGINT AS entregados,
        -- Pendientes: vigentes sin pagar
        COUNT(CASE
            WHEN ru.vigencia IN ('V', 'P', 'I') AND (ru.cvepago IS NULL OR ru.cvepago = 0) THEN 1
        END)::BIGINT AS pendientes,
        -- Vencidos: consideramos los vigentes antiguos como vencidos (simplificación)
        COUNT(CASE
            WHEN ru.vigencia = 'V' AND (ru.cvepago IS NULL OR ru.cvepago = 0) THEN 1
        END)::BIGINT AS vencidos,
        -- Cancelados
        COUNT(CASE WHEN ru.vigencia = 'C' THEN 1 END)::BIGINT AS cancelados,
        SUM(COALESCE(ru.monto, 0))::DECIMAL AS monto_total
    FROM requerimientos_unificados ru
    WHERE
        CASE
            WHEN q IS NULL OR q = '' THEN TRUE
            ELSE
                ru.ejecutor_nombre ILIKE '%' || q || '%'
                OR CAST(ru.cveejecut AS VARCHAR) = q
        END
    GROUP BY
        ru.ejecutor_nombre, ru.recaud
    ORDER BY
        total_requerimientos DESC, ejecutor, recaudadora
    LIMIT 500;
END;
$$;

-- Comentarios sobre el mapeo:
-- Se combinan datos de múltiples tablas de requerimientos:
--   - publico.reqmultas (403,146 registros)
--   - public.reqbflicencias (91,152 registros)
--   - public.reqanuncios (9,758 registros)
--   - public.reqbfpredial (118,842 registros)
--
-- Mapeo de campos:
-- cveejecut -> ejecutor (se hace JOIN con tabla ejecutor para obtener nombre)
-- recaud -> recaudadora (1=Predial, 2=Municipal, 3=Multas, 4=Licencias)
-- vigencia -> estatus:
--   - V, P, I = Pendientes
--   - E, F = Ejecutados/Entregados
--   - C = Cancelados
-- cvepago -> determina si fue pagado (entregado)
-- total/multas -> monto
--
-- Estados posibles en vigencia:
--   V = Vigente
--   C = Cancelado
--   P = Pendiente
--   I = Impreso
--   E = Ejecutado
--   F = Finalizado
