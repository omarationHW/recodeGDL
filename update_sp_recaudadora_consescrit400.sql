-- Actualización del Stored Procedure para consescrit400
-- Usa la tabla escrituras_400 del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_consescrit400(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_consescrit400(
    p_clave_cuenta TEXT DEFAULT ''
)
RETURNS TABLE (
    id_escritura INTEGER,
    clave_cuenta VARCHAR,
    numero_escritura VARCHAR,
    fecha_escritura DATE,
    notaria VARCHAR,
    notario VARCHAR,
    tipo_operacion VARCHAR,
    monto_operacion NUMERIC,
    nombre_adquirente VARCHAR,
    nombre_enajenante VARCHAR,
    superficie_terreno NUMERIC,
    superficie_construccion NUMERIC,
    ubicacion TEXT,
    impuesto_calculado NUMERIC,
    impuesto_pagado NUMERIC,
    fecha_pago DATE,
    referencia_pago VARCHAR,
    estado CHARACTER,
    fecha_registro TIMESTAMP,
    observaciones TEXT,
    dias_desde_registro INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.escritura AS id_escritura,
        e.cuenta::varchar AS clave_cuenta,
        CONCAT('ESC-', e.folio, '/', e.axofolio)::varchar AS numero_escritura,
        -- Convertir fecha de formato YYMMDD a DATE con validación
        CASE
            WHEN e.fecha IS NOT NULL AND e.fecha >= 700101 AND e.fecha <= 991231 THEN
                TO_DATE('19' || LPAD(e.fecha::text, 6, '0'), 'YYYYMMDD')
            WHEN e.fecha IS NOT NULL AND e.fecha >= 0 AND e.fecha <= 501231 THEN
                TO_DATE('20' || LPAD(e.fecha::text, 6, '0'), 'YYYYMMDD')
            ELSE NULL
        END AS fecha_escritura,
        CONCAT('Notaría ', COALESCE(e.notario, 0))::varchar AS notaria,
        COALESCE('Notario ' || e.notario::text, 'N/A')::varchar AS notario,
        'Escritura 400'::varchar AS tipo_operacion,
        0::numeric AS monto_operacion,
        'N/A'::varchar AS nombre_adquirente,
        'N/A'::varchar AS nombre_enajenante,
        0::numeric AS superficie_terreno,
        0::numeric AS superficie_construccion,
        CONCAT('Municipio: ', COALESCE(e.mpio, 0))::text AS ubicacion,
        0::numeric AS impuesto_calculado,
        0::numeric AS impuesto_pagado,
        NULL::date AS fecha_pago,
        TRIM(e.clave)::varchar AS referencia_pago,
        'A'::character AS estado,
        CASE
            WHEN e.fecha IS NOT NULL AND e.fecha >= 700101 AND e.fecha <= 991231 THEN
                TO_TIMESTAMP('19' || LPAD(e.fecha::text, 6, '0'), 'YYYYMMDD')::timestamp without time zone
            WHEN e.fecha IS NOT NULL AND e.fecha >= 0 AND e.fecha <= 501231 THEN
                TO_TIMESTAMP('20' || LPAD(e.fecha::text, 6, '0'), 'YYYYMMDD')::timestamp without time zone
            ELSE NULL
        END AS fecha_registro,
        CONCAT('Capturado por: ', TRIM(e.capturista))::text AS observaciones,
        CASE
            WHEN e.fecha IS NOT NULL AND e.fecha >= 700101 AND e.fecha <= 991231 THEN
                (CURRENT_DATE - TO_DATE('19' || LPAD(e.fecha::text, 6, '0'), 'YYYYMMDD'))::INTEGER
            WHEN e.fecha IS NOT NULL AND e.fecha >= 0 AND e.fecha <= 501231 THEN
                (CURRENT_DATE - TO_DATE('20' || LPAD(e.fecha::text, 6, '0'), 'YYYYMMDD'))::INTEGER
            ELSE NULL
        END AS dias_desde_registro
    FROM publico.escrituras_400 e
    WHERE
        e.cuenta::text = COALESCE(p_clave_cuenta, '')
    ORDER BY e.fecha DESC, e.escritura DESC;
END;
$$;
