CREATE OR REPLACE FUNCTION publico.recaudadora_pres(
    p_filtro VARCHAR
)
RETURNS TABLE (
    ejercicio INTEGER,
    titulo VARCHAR,
    capitulo VARCHAR,
    cta_aplicacion VARCHAR,
    fecha_ingreso DATE,
    presup_anual NUMERIC,
    ingreso_total NUMERIC,
    enero NUMERIC,
    febrero NUMERIC,
    marzo NUMERIC,
    abril NUMERIC,
    mayo NUMERIC,
    junio NUMERIC,
    julio NUMERIC,
    agosto NUMERIC,
    septiembre NUMERIC,
    octubre NUMERIC,
    noviembre NUMERIC,
    diciembre NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.ejercicio,
        p.titulo::VARCHAR,
        p.capitulo::VARCHAR,
        p.cta_aplicacion::VARCHAR,
        p.fecha_ingreso,
        p.presup_anual,
        p.ingreso_total,
        p.enero,
        p.febrero,
        p.marzo,
        p.abril,
        p.mayo,
        p.junio,
        p.julio,
        p.agosto,
        p.septiembre,
        p.octubre,
        p.noviembre,
        p.diciembre
    FROM publico.presupuesto_devengado p
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE p.ejercicio::TEXT ILIKE '%' || p_filtro || '%'
        END
    ORDER BY p.ejercicio DESC, p.titulo, p.capitulo;
END; $$;
