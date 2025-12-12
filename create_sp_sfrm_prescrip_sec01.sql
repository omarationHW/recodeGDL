CREATE OR REPLACE FUNCTION publico.recaudadora_sfrm_prescrip_sec01(
    p_filtro VARCHAR
)
RETURNS TABLE (
    id_prescri INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio VARCHAR,
    id_multa INTEGER,
    capturista VARCHAR,
    dependencia VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_prescri,
        p.fecaut,
        p.fecha_prescri,
        p.oficio::VARCHAR,
        p.id_multa,
        p.capturista::VARCHAR,
        p.dependencia::VARCHAR,
        p.observaciones
    FROM catastro_gdl.presc_multas p
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                p.id_multa::TEXT ILIKE '%' || p_filtro || '%'
                OR p.oficio ILIKE '%' || p_filtro || '%'
                OR p.dependencia ILIKE '%' || p_filtro || '%'
                OR p.capturista ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY p.fecaut DESC, p.id_prescri DESC;
END; $$;
