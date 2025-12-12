-- Stored Procedure: recaudadora_drecgo_fosa
-- Base de datos: multas_reglamentos
-- Esquema: public
-- Descripción: Consulta y gestión de fosas en panteones municipales por folio de control

CREATE OR REPLACE FUNCTION public.recaudadora_drecgo_fosa(
    p_folio INTEGER
)
RETURNS TABLE (
    id_control INTEGER,
    cementerio VARCHAR,
    clase VARCHAR,
    seccion VARCHAR,
    linea VARCHAR,
    fosa VARCHAR,
    nombre_titular VARCHAR,
    anio_minimo INTEGER,
    anio_maximo INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si p_folio es 0 o null, devuelve todas las fosas
    -- Si p_folio tiene un valor, filtra por ese folio
    RETURN QUERY
    SELECT
        f.id_control,
        f.cementerio,
        f.clase,
        f.seccion,
        f.linea,
        f.fosa,
        f.nombre_titular,
        f.anio_minimo,
        f.anio_maximo
    FROM
        public.fosas f
    WHERE
        CASE
            WHEN p_folio IS NULL OR p_folio = 0 THEN TRUE
            ELSE f.id_control = p_folio
        END
    ORDER BY
        f.id_control;
END;
$$;

-- Comentario descriptivo del procedimiento
COMMENT ON FUNCTION public.recaudadora_drecgo_fosa(INTEGER) IS
'Consulta fosas en panteones municipales. Parámetros: p_folio (INTEGER) - ID Control de la fosa, si es 0 devuelve todas las fosas.';
