CREATE OR REPLACE FUNCTION recaudadora_sol_sdos_favor(
    p_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_solic INTEGER,
    axofol SMALLINT,
    folio INTEGER,
    cvecuenta INTEGER,
    domp TEXT,
    extp TEXT,
    intp TEXT,
    colp TEXT,
    secp TEXT,
    codp INTEGER,
    telefono TEXT,
    solicitante TEXT,
    status TEXT,
    observaciones TEXT,
    feccap DATE,
    capturista TEXT,
    fecha_termino DATE,
    inconf SMALLINT,
    peticionario SMALLINT,
    doctos TEXT
) AS $$
DECLARE
    v_cuenta_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro de cuenta
    v_cuenta_trimmed := TRIM(p_cuenta);

    -- Buscar en tabla solic_sdosfavor (solicitudes de saldos a favor)
    RETURN QUERY
    SELECT
        s.id_solic,
        s.axofol,
        s.folio,
        s.cvecuenta,
        COALESCE(TRIM(s.domp), '')::TEXT as domp,
        COALESCE(TRIM(s.extp), '')::TEXT as extp,
        COALESCE(TRIM(s.intp), '')::TEXT as intp,
        COALESCE(TRIM(s.colp), '')::TEXT as colp,
        COALESCE(TRIM(s.secp), '')::TEXT as secp,
        s.codp,
        COALESCE(s.telefono, '')::TEXT as telefono,
        COALESCE(TRIM(s.solicitante), '')::TEXT as solicitante,
        COALESCE(TRIM(s.status), '')::TEXT as status,
        COALESCE(s.observaciones, '')::TEXT as observaciones,
        s.feccap,
        COALESCE(TRIM(s.capturista), '')::TEXT as capturista,
        s.fecha_termino,
        s.inconf,
        s.peticionario,
        COALESCE(s.doctos, '')::TEXT as doctos
    FROM catastro_gdl.solic_sdosfavor s
    WHERE (
        -- Si no hay filtro de cuenta, mostrar todos (ordenados por más recientes)
        v_cuenta_trimmed IS NULL OR v_cuenta_trimmed = ''
        -- Buscar por clave de cuenta
        OR s.cvecuenta::TEXT ILIKE '%' || v_cuenta_trimmed || '%'
        -- Buscar también por folio
        OR s.folio::TEXT ILIKE '%' || v_cuenta_trimmed || '%'
        -- Buscar por id_solic
        OR s.id_solic::TEXT ILIKE '%' || v_cuenta_trimmed || '%'
        -- Buscar por solicitante
        OR TRIM(s.solicitante) ILIKE '%' || v_cuenta_trimmed || '%'
    )
    ORDER BY s.id_solic DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar solicitudes de saldos a favor: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
