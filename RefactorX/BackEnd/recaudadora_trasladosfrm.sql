CREATE OR REPLACE FUNCTION recaudadora_trasladosfrm(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    ejercicio SMALLINT,
    dependencia INTEGER,
    partida SMALLINT,
    presup_anual NUMERIC,
    apliacion_auto NUMERIC,
    trans_aumento NUMERIC,
    trans_disminucion NUMERIC,
    ampliacion_nva NUMERIC
) AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar en tabla ta_transfer (transferencias presupuestarias / traslados)
    RETURN QUERY
    SELECT
        t.ejercicio,
        t.dependencia,
        t.partida,
        t.presup_anual,
        t.apliacion_auto,
        t.trans_aumento,
        t.trans_disminucion,
        t.ampliacion_nva
    FROM comun.ta_transfer t
    WHERE (
        -- Si no hay filtro, mostrar todos (ordenados por ejercicio desc)
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por ejercicio (año)
        OR t.ejercicio::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por dependencia
        OR t.dependencia::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por partida
        OR t.partida::TEXT ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY t.ejercicio DESC, t.dependencia, t.partida
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar traslados presupuestarios: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
