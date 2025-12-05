-- ================================================================
-- SP: recaudadora_consreq400
-- Módulo: multas_reglamentos
-- Descripción: Consulta requerimientos del AS-400 con paginación
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-28
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_consreq400(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    clave_cuenta VARCHAR,
    folio VARCHAR,
    ejercicio VARCHAR,
    estatus VARCHAR,
    fecha VARCHAR,
    fecent1 VARCHAR,
    fecent2 VARCHAR,
    prareq VARCHAR,
    fecpra VARCHAR,
    horapra VARCHAR,
    feccita VARCHAR,
    horacit VARCHAR,
    vigreq VARCHAR,
    dilreq VARCHAR,
    actreq VARCHAR,
    observr VARCHAR,
    ofnar VARCHAR,
    tpr VARCHAR,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar el total de registros que coinciden con los filtros
    SELECT COUNT(*)
    INTO v_total_count
    FROM catastro_gdl.req_400 r
    WHERE
        (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.ctarfc = p_clave_cuenta)
        AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR CAST(r.ejereq AS INTEGER) = p_ejercicio);

    -- Retornar los resultados paginados
    RETURN QUERY
    SELECT
        r.ctarfc AS clave_cuenta,
        r.folreq AS folio,
        r.ejereq AS ejercicio,
        CASE
            WHEN r.actreq IS NOT NULL AND r.actreq != '' THEN 'Activo'
            WHEN r.fecpagr IS NOT NULL AND r.fecpagr != '' THEN 'Pagado'
            ELSE 'Pendiente'
        END AS estatus,
        r.fecreq AS fecha,
        r.fecent1,
        r.fecent2,
        r.prareq,
        r.fecpra,
        r.horapra,
        r.feccita,
        r.horacit,
        r.vigreq,
        r.dilreq,
        r.actreq,
        r.observr,
        r.ofnar,
        r.tpr,
        v_total_count
    FROM catastro_gdl.req_400 r
    WHERE
        (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.ctarfc = p_clave_cuenta)
        AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR CAST(r.ejereq AS INTEGER) = p_ejercicio)
    ORDER BY r.folreq DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_consreq400(VARCHAR, INTEGER, INTEGER, INTEGER) IS 'Consulta requerimientos del AS-400 con filtros por cuenta y ejercicio, con paginación server-side.';
