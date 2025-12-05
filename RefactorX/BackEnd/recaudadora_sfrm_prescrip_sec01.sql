CREATE OR REPLACE FUNCTION recaudadora_sfrm_prescrip_sec01(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_prescri INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio TEXT,
    capturista TEXT,
    dependencia TEXT,
    observaciones TEXT,
    id_multa INTEGER
) AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar prescripciones
    RETURN QUERY
    SELECT
        pm.id_prescri,
        pm.fecaut,
        pm.fecha_prescri,
        COALESCE(TRIM(pm.oficio), '')::TEXT as oficio,
        COALESCE(TRIM(pm.capturista), '')::TEXT as capturista,
        COALESCE(TRIM(pm.dependencia), '')::TEXT as dependencia,
        COALESCE(pm.observaciones, '')::TEXT as observaciones,
        pm.id_multa
    FROM catastro_gdl.presc_multas pm
    WHERE (
        -- Si no hay filtro, mostrar todos (últimos 100)
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por ID prescripción
        OR pm.id_prescri::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por ID multa
        OR pm.id_multa::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por oficio
        OR TRIM(pm.oficio) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por capturista
        OR TRIM(pm.capturista) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por dependencia
        OR TRIM(pm.dependencia) ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por observaciones
        OR pm.observaciones ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY pm.id_prescri DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar prescripciones: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
