CREATE OR REPLACE FUNCTION publico.recaudadora_propuestatab(
    p_filtro VARCHAR
)
RETURNS TABLE (
    id_propuesta INTEGER,
    cvepago VARCHAR,
    cvecuenta VARCHAR,
    recaud VARCHAR,
    caja VARCHAR,
    folio VARCHAR,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cajero VARCHAR,
    cveconcepto VARCHAR,
    estado VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_propuesta,
        p.cvepago::VARCHAR,
        p.cvecuenta::VARCHAR,
        p.recaud::VARCHAR,
        p.caja::VARCHAR,
        p.folio::VARCHAR,
        p.fecha,
        p.hora,
        p.importe,
        p.cajero::VARCHAR,
        p.cveconcepto::VARCHAR,
        p.estado::VARCHAR
    FROM publico.propuestas_pago p
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                p.cvecuenta ILIKE '%' || p_filtro || '%'
                OR p.folio ILIKE '%' || p_filtro || '%'
                OR p.cajero ILIKE '%' || p_filtro || '%'
                OR p.cvepago ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY p.fecha DESC, p.hora DESC, p.id_propuesta DESC;
END; $$;
