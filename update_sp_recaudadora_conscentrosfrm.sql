-- Actualización del Stored Procedure para conscentrosfrm
-- Usa la tabla c_dependencias del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_conscentrosfrm(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_conscentrosfrm(
    p_query TEXT DEFAULT ''
)
RETURNS TABLE (
    id_centro INTEGER,
    clave VARCHAR,
    nombre VARCHAR,
    descripcion TEXT,
    direccion VARCHAR,
    telefono VARCHAR,
    responsable VARCHAR,
    tipo VARCHAR,
    estado CHARACTER,
    fecha_alta TIMESTAMP,
    fecha_modificacion TIMESTAMP
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_dependencia AS id_centro,
        COALESCE(TRIM(c.abrevia), c.id_dependencia::text)::varchar AS clave,
        TRIM(c.descripcion)::varchar AS nombre,
        'Dependencia municipal'::text AS descripcion,
        'N/A'::varchar AS direccion,
        'N/A'::varchar AS telefono,
        'N/A'::varchar AS responsable,
        CASE
            WHEN TRIM(c.tipo) = 'M' THEN 'Municipal'
            WHEN TRIM(c.tipo) = 'E' THEN 'Estatal'
            WHEN TRIM(c.tipo) = 'F' THEN 'Federal'
            ELSE COALESCE(TRIM(c.tipo), 'Sin tipo')
        END::varchar AS tipo,
        CASE
            WHEN c.vigencia = 'V' THEN 'A'::character
            WHEN c.vigencia = 'B' THEN 'B'::character
            WHEN c.vigencia = 'C' THEN 'C'::character
            ELSE 'I'::character
        END AS estado,
        COALESCE(c.feccap, CURRENT_DATE)::timestamp AS fecha_alta,
        COALESCE(c.feccap, CURRENT_DATE)::timestamp AS fecha_modificacion
    FROM publico.c_dependencias c
    WHERE
        COALESCE(p_query, '') = '' OR
        c.id_dependencia::text ILIKE '%' || p_query || '%' OR
        TRIM(c.abrevia) ILIKE '%' || p_query || '%' OR
        TRIM(c.descripcion) ILIKE '%' || p_query || '%' OR
        TRIM(c.tipo) ILIKE '%' || p_query || '%'
    ORDER BY c.id_dependencia;
END;
$$;
