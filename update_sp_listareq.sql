-- Actualización del Stored Procedure para listareq.vue
-- Usa las tablas existentes: publico.reqmultas, publico.multas

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_listareq'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_listareq(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal
CREATE OR REPLACE FUNCTION publico.recaudadora_listareq(
    p_clave_cuenta VARCHAR DEFAULT ''
)
RETURNS TABLE (
    folio VARCHAR,
    clave_cuenta VARCHAR,
    ejercicio VARCHAR,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    concepto VARCHAR,
    monto NUMERIC,
    fecha_emision DATE,
    estado VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(r.folioreq::TEXT, '')::VARCHAR AS folio,
        COALESCE(m.num_acta::TEXT || '/' || m.axo_acta::TEXT, '')::VARCHAR AS clave_cuenta,
        COALESCE(r.axoreq::TEXT, '')::VARCHAR AS ejercicio,
        TRIM(COALESCE(m.contribuyente, ''))::VARCHAR AS contribuyente,
        TRIM(COALESCE(m.domicilio, ''))::VARCHAR AS domicilio,
        CASE r.tipo
            WHEN 'N' THEN 'Normal'
            WHEN 'R' THEN 'Requerimiento'
            WHEN 'S' THEN 'Especial'
            WHEN 'D' THEN 'Diferencia'
            ELSE COALESCE(r.tipo, '')
        END::VARCHAR AS concepto,
        COALESCE(r.total, 0)::NUMERIC AS monto,
        r.fecemi AS fecha_emision,
        CASE r.vigencia
            WHEN 'V' THEN 'Vigente'
            WHEN 'C' THEN 'Cancelado'
            WHEN 'P' THEN 'Pagado'
            ELSE COALESCE(r.vigencia, '')
        END::VARCHAR AS estado,
        COALESCE(r.obs, '')::TEXT AS observaciones
    FROM publico.reqmultas r
    LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
    WHERE
        CASE
            WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
            ELSE (
                r.folioreq::TEXT ILIKE '%' || p_clave_cuenta || '%'
                OR m.num_acta::TEXT ILIKE '%' || p_clave_cuenta || '%'
                OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
            )
        END
    ORDER BY r.fecemi DESC, r.folioreq DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.reqmultas.folioreq -> folio (folio del requerimiento)
-- publico.multas.num_acta + axo_acta -> clave_cuenta (número de acta / año)
-- publico.reqmultas.axoreq -> ejercicio (año del requerimiento)
-- publico.multas.contribuyente -> contribuyente
-- publico.multas.domicilio -> domicilio
-- publico.reqmultas.tipo -> concepto (N=Normal, R=Requerimiento, S=Especial, D=Diferencia)
-- publico.reqmultas.total -> monto (monto total del requerimiento)
-- publico.reqmultas.fecemi -> fecha_emision
-- publico.reqmultas.vigencia -> estado (V=Vigente, C=Cancelado, P=Pagado)
-- publico.reqmultas.obs -> observaciones

-- PARÁMETROS:
-- p_clave_cuenta: Texto para búsqueda general (busca en folio, num_acta, contribuyente)

-- JOINS:
-- 1. publico.reqmultas LEFT JOIN publico.multas ON id_multa

-- FILTROS:
-- - Búsqueda general en folioreq, num_acta, contribuyente

-- ORDENAMIENTO:
-- - Por fecha de emisión descendente (más recientes primero)
-- - Por folio descendente (como criterio secundario)

-- LÍMITE:
-- - 100 registros para optimizar rendimiento

-- TIPOS DE DOCUMENTO:
-- N: Normal (233,854 registros)
-- R: Requerimiento (146,424 registros)
-- S: Especial (18,881 registros)
-- D: Diferencia (4,003 registros)

-- ESTADOS:
-- V: Vigente (113,972)
-- C: Cancelado (147,780)
-- P: Pagado (141,410)
