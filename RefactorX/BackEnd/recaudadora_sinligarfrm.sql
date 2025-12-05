CREATE OR REPLACE FUNCTION recaudadora_sinligarfrm(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_control INTEGER,
    cvepago INTEGER,
    cvecta INTEGER,
    usuario TEXT,
    fecha_act DATE,
    tipo INTEGER
) AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar en tabla qligapago (control de ligaduras de pagos)
    RETURN QUERY
    SELECT
        ql.id_control,
        ql.cvepago,
        ql.cvecta,
        COALESCE(TRIM(ql.usuario), '')::TEXT as usuario,
        ql.fecha_act,
        ql.tipo
    FROM comun.qligapago ql
    WHERE (
        -- Si no hay filtro, mostrar todos
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por ID control
        OR ql.id_control::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por clave de pago
        OR ql.cvepago::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por clave de cuenta
        OR ql.cvecta::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por usuario
        OR TRIM(ql.usuario) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por tipo
        OR ql.tipo::TEXT ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY ql.id_control DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar ligaduras de pagos: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
