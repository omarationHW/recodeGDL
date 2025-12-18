-- Actualización del Stored Procedure para drecgoLic
-- Corrige el campo coordenadas que no existe (usa x, y en su lugar)

DROP FUNCTION IF EXISTS publico.recaudadora_drecgolic(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_drecgolic(
    p_licencia VARCHAR
)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    domicilio VARCHAR,
    id_giro INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    coordenadas VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.licencia,
        -- Combinar propietario con apellidos
        TRIM(CONCAT(
            COALESCE(l.propietario, ''),
            CASE WHEN l.primer_ap IS NOT NULL AND TRIM(l.primer_ap) != ''
                THEN ' ' || TRIM(l.primer_ap) ELSE '' END,
            CASE WHEN l.segundo_ap IS NOT NULL AND TRIM(l.segundo_ap) != ''
                THEN ' ' || TRIM(l.segundo_ap) ELSE '' END
        ))::varchar AS propietario,
        COALESCE(TRIM(l.rfc), '')::varchar AS rfc,
        -- Combinar domicilio completo
        TRIM(CONCAT(
            COALESCE(l.domicilio, ''),
            CASE WHEN l.numext_prop IS NOT NULL AND l.numext_prop > 0
                THEN ' #' || l.numext_prop ELSE '' END,
            CASE WHEN l.numint_prop IS NOT NULL AND TRIM(l.numint_prop) != ''
                THEN ' INT ' || TRIM(l.numint_prop) ELSE '' END,
            CASE WHEN l.colonia_prop IS NOT NULL AND TRIM(l.colonia_prop) != ''
                THEN ', ' || TRIM(l.colonia_prop) ELSE '' END
        ))::varchar AS domicilio,
        l.id_giro,
        l.zona,
        l.subzona,
        l.cvecuenta,
        l.fecha_otorgamiento,
        -- Combinar coordenadas x, y en formato "x,y"
        CASE
            WHEN l.x IS NOT NULL AND l.y IS NOT NULL THEN
                CONCAT(l.x::text, ',', l.y::text)
            ELSE ''
        END::varchar AS coordenadas
    FROM publico.licencias l
    WHERE
        CASE
            WHEN p_licencia IS NULL OR p_licencia = '' THEN TRUE
            ELSE l.licencia::text ILIKE '%' || p_licencia || '%'
              OR COALESCE(l.propietario, '') ILIKE '%' || p_licencia || '%'
              OR COALESCE(l.primer_ap, '') ILIKE '%' || p_licencia || '%'
              OR COALESCE(l.segundo_ap, '') ILIKE '%' || p_licencia || '%'
              OR COALESCE(l.rfc, '') ILIKE '%' || p_licencia || '%'
              OR l.id_licencia::text = p_licencia
        END
    ORDER BY l.id_licencia
    LIMIT 100;
END;
$$;

-- Comentarios sobre el mapeo:
-- id_licencia -> id_licencia (identificador único)
-- licencia -> licencia (número de licencia)
-- propietario + primer_ap + segundo_ap -> propietario (nombre completo)
-- rfc -> rfc (RFC del propietario)
-- domicilio + numext_prop + numint_prop + colonia_prop -> domicilio (domicilio completo)
-- id_giro -> id_giro (giro comercial)
-- zona -> zona
-- subzona -> subzona
-- cvecuenta -> cvecuenta (cuenta relacionada)
-- fecha_otorgamiento -> fecha_otorgamiento
-- x, y -> coordenadas (combinadas en formato "x,y")
