CREATE OR REPLACE FUNCTION recaudadora_tdm_conection(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado TEXT,
    id_rec SMALLINT,
    nivel SMALLINT,
    clave TEXT,
    perfiles_id INTEGER
) AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar en tabla conexion (usuarios y conexiones TDM)
    RETURN QUERY
    SELECT
        c.id_usuario,
        COALESCE(TRIM(c.usuario), '')::TEXT as usuario,
        COALESCE(TRIM(c.nombre), '')::TEXT as nombre,
        COALESCE(TRIM(c.estado), '')::TEXT as estado,
        c.id_rec,
        c.nivel,
        COALESCE(TRIM(c.clave), '')::TEXT as clave,
        c.perfiles_id
    FROM comun.conexion c
    WHERE (
        -- Si no hay filtro, mostrar todos (ordenados por ID descendente)
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por ID usuario
        OR c.id_usuario::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por usuario
        OR TRIM(c.usuario) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por nombre
        OR TRIM(c.nombre) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por estado
        OR TRIM(c.estado) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por recaudadora
        OR c.id_rec::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por nivel
        OR c.nivel::TEXT ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY c.id_usuario DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar conexiones TDM: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
