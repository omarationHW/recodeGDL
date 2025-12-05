CREATE OR REPLACE FUNCTION recaudadora_sgcv2(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    ejercicio INTEGER,
    centro_id INTEGER,
    tipo_doc_id INTEGER,
    numero INTEGER,
    nombre_generico TEXT,
    fecha_documento DATE,
    fecha_registro TIMESTAMP,
    fecha_limite TIMESTAMP,
    tipo_control TEXT,
    prioridad_id INTEGER,
    status_id INTEGER,
    usuario TEXT
) AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar en tabla t42_control (Sistema de Control de Trámites)
    RETURN QUERY
    SELECT
        tc.id,
        tc.ejercicico as ejercicio,
        tc.t42_centros_id as centro_id,
        tc.t42_tipodocs_id as tipo_doc_id,
        tc.numero,
        COALESCE(tc.nombre_generico, '')::TEXT as nombre_generico,
        tc.fec_docto as fecha_documento,
        tc.fec_rgs as fecha_registro,
        tc.fec_limite as fecha_limite,
        COALESCE(tc.tipo_control, '')::TEXT as tipo_control,
        tc.t42_prioridad_id as prioridad_id,
        tc.t42_status_id as status_id,
        COALESCE(TRIM(tc.usuario_mov), '')::TEXT as usuario
    FROM comun.t42_control tc
    WHERE (
        -- Si no hay filtro, mostrar todos (últimos 100)
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por ID
        OR tc.id::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por número
        OR tc.numero::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por nombre genérico
        OR tc.nombre_generico ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por ejercicio
        OR tc.ejercicico::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por usuario
        OR TRIM(tc.usuario_mov) ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY tc.id DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar SGC: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
