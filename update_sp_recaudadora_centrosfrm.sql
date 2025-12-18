-- Actualización del Stored Procedure para centrosfrm
-- Usa la tabla c_dependencias del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_centrosfrm(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_centrosfrm(
    p_query TEXT
)
RETURNS TABLE (
    id_centro INTEGER,
    clave_centro TEXT,
    nombre_centro TEXT,
    tipo_centro TEXT,
    direccion TEXT,
    telefono TEXT,
    responsable TEXT,
    status TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_dependencia::integer AS id_centro,
        COALESCE(TRIM(c.abrevia), c.id_dependencia::text)::text AS clave_centro,
        COALESCE(TRIM(c.descripcion), 'Sin nombre')::text AS nombre_centro,
        CASE
            WHEN c.tipo = 'M' THEN 'Municipal'
            WHEN c.tipo = 'E' THEN 'Estatal'
            WHEN c.tipo = 'F' THEN 'Federal'
            ELSE COALESCE(TRIM(c.tipo), 'Sin tipo')
        END::text AS tipo_centro,
        'N/A'::text AS direccion,
        'N/A'::text AS telefono,
        'N/A'::text AS responsable,
        CASE
            WHEN c.vigencia = 'V' THEN 'ACTIVO'
            WHEN c.vigencia = 'B' THEN 'BAJA'
            WHEN c.vigencia = 'C' THEN 'CANCELADO'
            ELSE 'INACTIVO'
        END::text AS status
    FROM publico.c_dependencias c
    WHERE c.vigencia = 'V'
      AND (p_query = '' OR p_query IS NULL OR
           TRIM(c.abrevia) ILIKE '%' || p_query || '%' OR
           TRIM(c.descripcion) ILIKE '%' || p_query || '%' OR
           c.id_dependencia::text ILIKE '%' || p_query || '%' OR
           TRIM(c.tipo) ILIKE '%' || p_query || '%')
    ORDER BY TRIM(c.descripcion);
END;
$$;
