CREATE OR REPLACE FUNCTION recaudadora_sfrm_calificacionqr(
    p_cuenta VARCHAR DEFAULT NULL,
    p_folio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_multa INTEGER,
    folio INTEGER,
    contribuyente TEXT,
    domicilio TEXT,
    calificacion NUMERIC(12,2),
    multa NUMERIC(12,2),
    total NUMERIC(12,2),
    fecha_acta DATE,
    tipo_calificacion_cod TEXT,
    tipo_calificacion_desc TEXT,
    usuario_calificacion TEXT,
    fecha_calificacion TIMESTAMP,
    expediente TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta as folio,
        COALESCE(TRIM(m.contribuyente), 'N/A')::TEXT as contribuyente,
        COALESCE(TRIM(m.domicilio), 'N/A')::TEXT as domicilio,
        COALESCE(m.calificacion, 0) as calificacion,
        COALESCE(m.multa, 0) as multa,
        COALESCE(m.total, 0) as total,
        m.fecha_acta,
        TRIM(tc.tipo_calificacion)::TEXT as tipo_calificacion_cod,
        CASE
            WHEN TRIM(tc.tipo_calificacion) = 'M' THEN 'Manual/Modificada'::TEXT
            WHEN TRIM(tc.tipo_calificacion) = 'O' THEN 'Ordinaria'::TEXT
            ELSE 'Otro'::TEXT
        END as tipo_calificacion_desc,
        COALESCE(TRIM(tc.usuario), 'N/A')::TEXT as usuario_calificacion,
        tc.fecha_actual as fecha_calificacion,
        COALESCE(TRIM(m.expediente), 'N/A')::TEXT as expediente
    FROM catastro_gdl.multas m
    INNER JOIN catastro_gdl.tipo_calificacion_multa tc ON tc.id_multa = m.id_multa
    WHERE (
        (p_cuenta IS NULL OR p_cuenta = '' OR m.id_multa::TEXT ILIKE '%' || p_cuenta || '%')
        OR
        (p_folio IS NULL OR p_folio = '' OR m.num_acta::TEXT ILIKE '%' || p_folio || '%')
    )
    ORDER BY m.id_multa DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
