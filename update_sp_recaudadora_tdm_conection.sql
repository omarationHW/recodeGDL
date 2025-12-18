-- Actualización del Stored Procedure para TDMConection
-- Usa la tabla usuarios del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_tdm_conection(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_tdm_conection(
    p_filtro TEXT
)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado CHARACTER,
    id_rec INTEGER,
    nivel SMALLINT,
    clave TEXT,
    perfiles_id INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY TRIM(t.usuario))::integer AS id_usuario,
        TRIM(t.usuario)::text AS usuario,
        TRIM(t.nombres)::text AS nombre,
        CASE
            WHEN t.fecbaj IS NULL THEN 'A'::character
            ELSE 'I'::character
        END AS estado,
        COALESCE(t.cvedepto, 0)::integer AS id_rec,
        COALESCE(t.nivel, 0)::smallint AS nivel,
        CASE
            WHEN t.clave IS NOT NULL AND TRIM(t.clave) != '' THEN '***'
            ELSE NULL
        END::text AS clave,
        0::integer AS perfiles_id
    FROM publico.usuarios t
    WHERE (p_filtro = '' OR p_filtro IS NULL OR
           TRIM(t.usuario) ILIKE '%' || p_filtro || '%' OR
           TRIM(t.nombres) ILIKE '%' || p_filtro || '%' OR
           t.cvedepto::text ILIKE '%' || p_filtro || '%' OR
           t.nivel::text ILIKE '%' || p_filtro || '%')
    ORDER BY TRIM(t.usuario);
END;
$$;
