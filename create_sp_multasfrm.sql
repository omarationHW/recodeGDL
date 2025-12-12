CREATE FUNCTION publico.recaudadora_multasfrm(p_filtro VARCHAR)
RETURNS TABLE (
    id_multa INTEGER, folio VARCHAR, anio INTEGER, fecha_acta DATE,
    contribuyente VARCHAR, domicilio VARCHAR, giro VARCHAR, licencia VARCHAR,
    total NUMERIC, estatus VARCHAR
)
LANGUAGE plpgsql AS $$ BEGIN
    RETURN QUERY
    SELECT m.id_multa, m.folio, m.anio, m.fecha_acta, m.contribuyente,
           m.domicilio, m.giro, m.licencia, m.total, m.estatus
    FROM publico.multas_general m
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                m.folio ILIKE '%' || p_filtro || '%'
                OR m.contribuyente ILIKE '%' || p_filtro || '%'
                OR m.domicilio ILIKE '%' || p_filtro || '%'
                OR m.giro ILIKE '%' || p_filtro || '%'
                OR m.licencia ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY m.fecha_acta DESC, m.id_multa DESC;
END; $$;
