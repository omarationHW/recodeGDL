CREATE FUNCTION publico.recaudadora_multas_dm(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER,
    p_offset INTEGER,
    p_limit INTEGER
)
RETURNS TABLE (
    clave_cuenta VARCHAR, folio VARCHAR, ejercicio INTEGER,
    importe NUMERIC, estatus VARCHAR, total_registros BIGINT
)
LANGUAGE plpgsql AS $$ 
DECLARE
    v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM publico.multas_dm m
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR m.ejercicio = p_ejercicio);

    RETURN QUERY
    SELECT m.clave_cuenta, m.folio, m.ejercicio, m.importe, m.estatus, v_total AS total_registros
    FROM publico.multas_dm m
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR m.ejercicio = p_ejercicio)
    ORDER BY m.ejercicio DESC, m.folio DESC
    LIMIT p_limit
    OFFSET p_offset;
END; $$;
