-- Actualización del Stored Procedure para DrecgoFosa
-- Usa la tabla ta_13_datosrcm del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_drecgo_fosa(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_drecgo_fosa(
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
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.control_rcm AS id_control,
        -- Combinar código de cementerio con nombre del catálogo
        CONCAT(
            TRIM(f.cementerio), ' - ',
            COALESCE(c.nombre, 'Desconocido')
        )::varchar AS cementerio,
        -- Usar clase_alfa si existe, sino el número
        COALESCE(
            NULLIF(TRIM(f.clase_alfa), ''),
            f.clase::varchar
        )::varchar AS clase,
        -- Usar seccion_alfa si existe, sino el número
        COALESCE(
            NULLIF(TRIM(f.seccion_alfa), ''),
            f.seccion::varchar
        )::varchar AS seccion,
        -- Usar linea_alfa si existe, sino el número
        COALESCE(
            NULLIF(TRIM(f.linea_alfa), ''),
            f.linea::varchar
        )::varchar AS linea,
        -- Usar fosa_alfa si existe, sino el número
        COALESCE(
            NULLIF(TRIM(f.fosa_alfa), ''),
            f.fosa::varchar
        )::varchar AS fosa,
        -- Nombre del titular
        COALESCE(TRIM(f.nombre), '')::varchar AS nombre_titular,
        -- Año pagado como año mínimo (se podría calcular mejor)
        f.axo_pagado AS anio_minimo,
        -- Año actual como año máximo (asumiendo vigencia)
        CASE
            WHEN f.vigencia = 'V' THEN EXTRACT(YEAR FROM CURRENT_DATE)::integer
            ELSE f.axo_pagado
        END AS anio_maximo
    FROM publico.ta_13_datosrcm f
    LEFT JOIN publico.tc_13_cementerios c ON f.cementerio = c.cementerio
    WHERE
        CASE
            WHEN p_folio IS NULL OR p_folio = 0 THEN TRUE
            ELSE f.control_rcm = p_folio
        END
        AND f.vigencia = 'V'  -- Solo registros vigentes
    ORDER BY f.control_rcm
    LIMIT 100;
END;
$$;

-- Comentarios sobre el mapeo:
-- control_rcm -> id_control (identificador único de la fosa)
-- cementerio -> cementerio (código del cementerio + nombre del catálogo)
-- clase/clase_alfa -> clase (tipo de fosa)
-- seccion/seccion_alfa -> seccion (sección dentro del cementerio)
-- linea/linea_alfa -> linea (línea dentro de la sección)
-- fosa/fosa_alfa -> fosa (número de fosa)
-- nombre -> nombre_titular (titular de la fosa)
-- axo_pagado -> anio_minimo (último año pagado)
-- año_actual (si vigente) -> anio_maximo (año hasta el cual está vigente)
