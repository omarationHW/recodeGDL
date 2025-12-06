CREATE OR REPLACE FUNCTION recaudadora_ubicodifica(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecuenta INTEGER,
    domicilio TEXT,
    noexterior TEXT,
    interior TEXT,
    colonia TEXT,
    observaciones TEXT,
    fec_alta DATE,
    usuario_alta TEXT,
    vigencia TEXT,
    fec_baja DATE,
    fec_mov DATE,
    usuario_mov TEXT
) AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar en tabla ubicacion_req (requerimientos de ubicación/codificación)
    RETURN QUERY
    SELECT
        u.cvecuenta,
        COALESCE(u.domicilio, '')::TEXT as domicilio,
        COALESCE(TRIM(u.noexterior), '')::TEXT as noexterior,
        COALESCE(TRIM(u.interior), '')::TEXT as interior,
        COALESCE(u.colonia, '')::TEXT as colonia,
        COALESCE(u.observaciones, '')::TEXT as observaciones,
        u.fec_alta,
        COALESCE(TRIM(u.usuario_alta), '')::TEXT as usuario_alta,
        COALESCE(TRIM(u.vigencia), '')::TEXT as vigencia,
        u.fec_baja,
        u.fec_mov,
        COALESCE(TRIM(u.usuario_mov), '')::TEXT as usuario_mov
    FROM catastro_gdl.ubicacion_req u
    WHERE (
        -- Si no hay filtro, mostrar todos (vigentes primero)
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por cuenta
        OR u.cvecuenta::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por domicilio
        OR u.domicilio ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por número exterior
        OR TRIM(u.noexterior) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por colonia
        OR u.colonia ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por observaciones
        OR u.observaciones ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY
        CASE WHEN u.vigencia = 'V' THEN 0 ELSE 1 END, -- Vigentes primero
        u.fec_alta DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar ubicaciones/codificación: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
