-- ================================================================
-- SP: recaudadora_drecgo_fosa
-- Módulo: multas_reglamentos
-- Descripción: Consulta derechos de fosa (panteones)
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-30
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_drecgo_fosa(
    p_folio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_control TEXT,
    cementerio TEXT,
    clase TEXT,
    seccion TEXT,
    linea TEXT,
    fosa TEXT,
    nombre_titular TEXT,
    anio_minimo TEXT,
    anio_maximo TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar derechos de fosa
    RETURN QUERY
    SELECT
        CAST(f.id_control AS TEXT) AS id_control,
        CAST(
            CASE
                WHEN f.cem = 'G' THEN 'Guadalajara'
                WHEN f.cem = 'M' THEN 'Mezquitán'
                ELSE f.cem
            END AS TEXT
        ) AS cementerio,
        CAST(f.clase AS TEXT) AS clase,
        CAST(f.secc AS TEXT) AS seccion,
        CAST(f.linea AS TEXT) AS linea,
        CAST(f.fosa AS TEXT) AS fosa,
        CAST(TRIM(f.nombre) AS TEXT) AS nombre_titular,
        CAST(f.minimo AS TEXT) AS anio_minimo,
        CAST(f.maximo AS TEXT) AS anio_maximo
    FROM catastro_gdl.v_fosa f
    WHERE
        (p_folio IS NULL OR p_folio = 0 OR f.id_control = p_folio)
    ORDER BY f.id_control;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_drecgo_fosa(INTEGER) IS 'Consulta derechos de fosa (panteones) desde catastro_gdl.v_fosa.';
