CREATE FUNCTION publico.recaudadora_multasfrmcalif(
    p_clave_cuenta VARCHAR,
    p_offset INTEGER,
    p_limit INTEGER
)
RETURNS TABLE (
    id_multa INTEGER, folio VARCHAR, anio INTEGER, fecha_acta DATE,
    clave_cuenta VARCHAR, contribuyente VARCHAR, ley VARCHAR, infraccion VARCHAR,
    calificacion NUMERIC, multa NUMERIC, gastos NUMERIC, total NUMERIC,
    estatus VARCHAR, total_registros BIGINT
)
LANGUAGE plpgsql AS $$ 
DECLARE
    v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM publico.multas_calificacion m
    WHERE
        CASE
            WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
            ELSE (
                m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                OR m.folio ILIKE '%' || p_clave_cuenta || '%'
                OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
            )
        END;

    RETURN QUERY
    SELECT m.id_multa, m.folio, m.anio, m.fecha_acta, m.clave_cuenta,
           m.contribuyente, m.ley, m.infraccion, m.calificacion, m.multa,
           m.gastos, m.total, m.estatus, v_total AS total_registros
    FROM publico.multas_calificacion m
    WHERE
        CASE
            WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
            ELSE (
                m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                OR m.folio ILIKE '%' || p_clave_cuenta || '%'
                OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
            )
        END
    ORDER BY m.fecha_acta DESC, m.id_multa DESC
    LIMIT p_limit
    OFFSET p_offset;
END; $$;
