-- Actualización del Stored Procedure para ConsReq400
-- Usa la tabla reqmultas del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_consreq400(TEXT, INTEGER, INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_consreq400(
    p_clave_cuenta TEXT DEFAULT '',
    p_ejercicio INTEGER DEFAULT 0,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_requerimiento INTEGER,
    clave_cuenta VARCHAR,
    folio VARCHAR,
    ejercicio INTEGER,
    estatus VARCHAR,
    fecha DATE,
    fecent1 DATE,
    fecent2 DATE,
    fecpra DATE,
    horapra TIME,
    feccita DATE,
    horacit TIME,
    prareq VARCHAR,
    vigreq VARCHAR,
    dilreq VARCHAR,
    actreq VARCHAR,
    ofnar VARCHAR,
    tpr VARCHAR,
    observr TEXT,
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    total_count BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros que cumplen los filtros
    SELECT COUNT(*)
    INTO v_total_count
    FROM publico.reqmultas r
    WHERE
        (p_clave_cuenta = '' OR r.id_multa::text = p_clave_cuenta)
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio);

    -- Retornar registros paginados con mapeo de campos
    RETURN QUERY
    SELECT
        r.cvereq AS id_requerimiento,
        COALESCE(r.id_multa::varchar, '') AS clave_cuenta,
        COALESCE(r.folioreq::varchar, '') AS folio,
        COALESCE(r.axoreq::integer, 0) AS ejercicio,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'::varchar
            WHEN r.vigencia = 'C' THEN 'Cancelado'::varchar
            WHEN r.vigencia = 'P' THEN 'Pagado'::varchar
            ELSE 'Desconocido'::varchar
        END AS estatus,
        r.fecemi AS fecha,
        r.feccit AS fecent1,
        r.fecpract AS fecent2,
        r.fecpract AS fecpra,
        CASE
            WHEN r.horapract IS NOT NULL AND LENGTH(TRIM(r.horapract)) >= 4 THEN
                (SUBSTRING(TRIM(r.horapract), 1, 2) || ':' || SUBSTRING(TRIM(r.horapract), 3, 2) || ':00')::time
            ELSE NULL
        END AS horapra,
        r.feccit AS feccita,
        CASE
            WHEN r.horacit IS NOT NULL AND LENGTH(TRIM(r.horacit)) >= 4 THEN
                (SUBSTRING(TRIM(r.horacit), 1, 2) || ':' || SUBSTRING(TRIM(r.horacit), 3, 2) || ':00')::time
            ELSE NULL
        END AS horacit,
        COALESCE(r.tipo, '')::varchar AS prareq,
        COALESCE(r.vigencia, '')::varchar AS vigreq,
        COALESCE(r.nodiligenciado, '')::varchar AS dilreq,
        ''::varchar AS actreq,
        COALESCE(r.cveejecut::varchar, '') AS ofnar,
        COALESCE(r.tipo, '')::varchar AS tpr,
        COALESCE(r.obs, '') AS observr,
        COALESCE(r.feccap, r.fecemi)::timestamp AS fecha_registro,
        COALESCE(r.fecejec, r.fecemi)::timestamp AS fecha_actualizacion,
        v_total_count AS total_count
    FROM publico.reqmultas r
    WHERE
        (p_clave_cuenta = '' OR r.id_multa::text = p_clave_cuenta)
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
    ORDER BY r.cvereq DESC
    OFFSET p_offset
    LIMIT p_limit;
END;
$$;

-- Comentarios sobre el mapeo:
-- cvereq -> id_requerimiento
-- id_multa -> clave_cuenta (cuenta de la multa)
-- folioreq -> folio
-- axoreq -> ejercicio (año del requerimiento)
-- vigencia -> estatus (V=Vigente, C=Cancelado, P=Pagado)
-- fecemi -> fecha
-- feccit -> fecent1 y feccita
-- fecpract -> fecent2 y fecpra
-- horapract -> horapra (convertido a TIME)
-- horacit -> horacit (convertido a TIME)
-- tipo -> prareq y tpr
-- nodiligenciado -> dilreq
-- cveejecut -> ofnar
-- obs -> observr
