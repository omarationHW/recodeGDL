CREATE FUNCTION publico.recaudadora_multas400frm(p_filtro VARCHAR)
RETURNS TABLE (
    id_multa INTEGER, num_acta VARCHAR, axo_acta INTEGER, fecha_acta DATE,
    contribuyente VARCHAR, domicilio VARCHAR, id_dependencia VARCHAR, expediente VARCHAR,
    multa NUMERIC, gastos NUMERIC, total NUMERIC, cvepago VARCHAR,
    fecha_recepcion DATE, observacion TEXT
) LANGUAGE plpgsql AS $$ BEGIN
    RETURN QUERY
    SELECT m.id_multa, m.num_acta, m.axo_acta, m.fecha_acta, m.contribuyente,
           m.domicilio, m.id_dependencia, m.expediente, m.multa, m.gastos,
           m.total, m.cvepago, m.fecha_recepcion, m.observacion
    FROM publico.multas_400 m
    WHERE CASE
        WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
        ELSE (m.id_multa::TEXT ILIKE '%' || p_filtro || '%'
              OR m.num_acta ILIKE '%' || p_filtro || '%'
              OR m.contribuyente ILIKE '%' || p_filtro || '%'
              OR m.expediente ILIKE '%' || p_filtro || '%'
              OR m.id_dependencia ILIKE '%' || p_filtro || '%'
              OR m.cvepago ILIKE '%' || p_filtro || '%')
    END
    ORDER BY m.fecha_acta DESC, m.id_multa DESC;
END; $$;
