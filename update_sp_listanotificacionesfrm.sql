-- Actualización del Stored Procedure para listanotificacionesfrm.vue
-- Usa las tablas existentes: publico.reqmultas, publico.multas, publico.c_dependencias

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_listanotificacionesfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_listanotificacionesfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal
CREATE OR REPLACE FUNCTION publico.recaudadora_listanotificacionesfrm(
    p_reca INTEGER,
    p_axo INTEGER,
    p_inicio INTEGER,
    p_final INTEGER,
    p_tipo VARCHAR,
    p_orden VARCHAR DEFAULT 'lote'
)
RETURNS TABLE (
    abrevia VARCHAR,
    axo_acta VARCHAR,
    num_acta VARCHAR,
    num_lote VARCHAR,
    folioreq VARCHAR,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    total NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(COALESCE(d.abrevia, ''))::VARCHAR AS abrevia,
        COALESCE(m.axo_acta::TEXT, '')::VARCHAR AS axo_acta,
        COALESCE(m.num_acta::TEXT, '')::VARCHAR AS num_acta,
        COALESCE(m.num_lote::TEXT, '')::VARCHAR AS num_lote,
        COALESCE(r.folioreq::TEXT, '')::VARCHAR AS folioreq,
        TRIM(COALESCE(m.contribuyente, 'SIN ESPECIFICAR'))::VARCHAR AS contribuyente,
        TRIM(COALESCE(m.domicilio, ''))::VARCHAR AS domicilio,
        COALESCE(r.total, 0)::NUMERIC AS total
    FROM publico.reqmultas r
    LEFT JOIN publico.multas m ON r.id_multa = m.id_multa
    LEFT JOIN publico.c_dependencias d ON m.id_dependencia = d.id_dependencia
    WHERE r.recaud = p_reca
      AND m.axo_acta = p_axo
      AND r.folioreq BETWEEN p_inicio AND p_final
      AND r.tipo = p_tipo
    ORDER BY
        CASE
            WHEN p_orden = 'lote' THEN COALESCE(m.num_lote::TEXT, '0')
            WHEN p_orden = 'vigentes' THEN COALESCE(r.folioreq::TEXT, '0')
            WHEN p_orden = 'dependencia' THEN TRIM(COALESCE(d.abrevia, '')) || COALESCE(m.num_acta::TEXT, '0')
            ELSE COALESCE(m.num_lote::TEXT, '0')
        END;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.c_dependencias.abrevia -> abrevia (abreviatura de la dependencia)
-- publico.multas.axo_acta -> axo_acta (año del acta)
-- publico.multas.num_acta -> num_acta (número de acta)
-- publico.multas.num_lote -> num_lote (número de lote)
-- publico.reqmultas.folioreq -> folioreq (folio del requerimiento)
-- publico.multas.contribuyente -> contribuyente
-- publico.multas.domicilio -> domicilio
-- publico.reqmultas.total -> total (monto total del requerimiento)

-- PARÁMETROS:
-- p_reca: Recaudadora (1-10)
-- p_axo: Año del acta
-- p_inicio: Folio de requerimiento inicio
-- p_final: Folio de requerimiento final
-- p_tipo: Tipo de documento (N=Normal, R=Requerimiento, S=?, D=Diferencia)
-- p_orden: Orden de resultados ('lote', 'vigentes', 'dependencia')

-- JOINS:
-- 1. publico.reqmultas LEFT JOIN publico.multas ON id_multa
-- 2. publico.multas LEFT JOIN publico.c_dependencias ON id_dependencia

-- FILTROS:
-- - Recaudadora exacta (r.recaud = p_reca)
-- - Año del acta exacto (m.axo_acta = p_axo)
-- - Rango de folios (r.folioreq BETWEEN p_inicio AND p_final)
-- - Tipo de documento (r.tipo = p_tipo)

-- ORDENAMIENTO:
-- - 'lote': Por número de lote
-- - 'vigentes': Por folio de requerimiento
-- - 'dependencia': Por abreviatura + número de acta

-- TIPOS DE DOCUMENTO:
-- N: Normal (233,854 registros)
-- R: Requerimiento (146,424 registros)
-- S: ? (18,881 registros)
-- D: Diferencia (4,003 registros)

-- ESTADOS:
-- V: Vigente (113,972)
-- C: Cancelado (147,780)
-- P: Pagado (141,410)
