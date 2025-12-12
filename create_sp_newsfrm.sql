CREATE FUNCTION publico.recaudadora_newsfrm(
    p_filtro VARCHAR,
    p_offset INTEGER,
    p_limit INTEGER
)
RETURNS TABLE (
    id_multa INTEGER, folio VARCHAR, anio INTEGER, fecha_acta DATE,
    fecha_recepcion DATE, contribuyente VARCHAR, domicilio VARCHAR,
    total NUMERIC, estatus VARCHAR, total_registros BIGINT
)
LANGUAGE plpgsql AS $$ 
DECLARE
    v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM publico.multas_novedades m
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                m.folio ILIKE '%' || p_filtro || '%'
                OR m.contribuyente ILIKE '%' || p_filtro || '%'
                OR m.anio::TEXT ILIKE '%' || p_filtro || '%'
            )
        END;

    RETURN QUERY
    SELECT m.id_multa, m.folio, m.anio, m.fecha_acta, m.fecha_recepcion,
           m.contribuyente, m.domicilio, m.total, m.estatus, v_total AS total_registros
    FROM publico.multas_novedades m
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                m.folio ILIKE '%' || p_filtro || '%'
                OR m.contribuyente ILIKE '%' || p_filtro || '%'
                OR m.anio::TEXT ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY m.fecha_recepcion DESC NULLS LAST, m.fecha_acta DESC, m.id_multa DESC
    LIMIT p_limit
    OFFSET p_offset;
END; $$;
