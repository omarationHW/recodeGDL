-- Actualización del Stored Procedure para consobsmulfrm
-- Usa la tabla reqmulta_obs_hist del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_consobsmulfrm(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_consobsmulfrm(
    p_filtro TEXT DEFAULT ''
)
RETURNS TABLE (
    id_observacion INTEGER,
    folio_multa VARCHAR,
    tipo_observacion VARCHAR,
    observacion TEXT,
    fecha_observacion TIMESTAMP,
    usuario VARCHAR,
    dependencia VARCHAR,
    prioridad VARCHAR,
    estado CHARACTER,
    fecha_resolucion TIMESTAMP,
    resolucion TEXT,
    observaciones_adicionales TEXT,
    fecha_registro TIMESTAMP,
    dias_desde_observacion INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY o.fecha_movimiento DESC, o.cvereq DESC)::INTEGER AS id_observacion,
        o.cvereq::varchar AS folio_multa,
        'Observación de requerimiento'::varchar AS tipo_observacion,
        COALESCE(o.observacion, 'Sin observación')::text AS observacion,
        o.fecha_movimiento::timestamp AS fecha_observacion,
        COALESCE(TRIM(o.capturista), 'SISTEMA')::varchar AS usuario,
        'N/A'::varchar AS dependencia,
        'Normal'::varchar AS prioridad,
        'A'::character AS estado,
        NULL::timestamp AS fecha_resolucion,
        'N/A'::text AS resolucion,
        CONCAT('Requerimiento: ', o.cvereq)::text AS observaciones_adicionales,
        o.fecha_movimiento::timestamp AS fecha_registro,
        CASE
            WHEN o.fecha_movimiento IS NOT NULL THEN
                (CURRENT_DATE - o.fecha_movimiento)::INTEGER
            ELSE NULL
        END AS dias_desde_observacion
    FROM publico.reqmulta_obs_hist o
    WHERE
        COALESCE(p_filtro, '') = '' OR
        o.cvereq::text ILIKE '%' || p_filtro || '%' OR
        o.observacion ILIKE '%' || p_filtro || '%' OR
        TRIM(o.capturista) ILIKE '%' || p_filtro || '%'
    ORDER BY o.fecha_movimiento DESC, o.cvereq DESC;
END;
$$;
