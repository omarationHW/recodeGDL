-- ================================================================
-- SP: recaudadora_reqctascanfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta de requerimientos de cuentas canceladas
-- Parámetros:
--   clave_cuenta: Clave de cuenta en formato "AÑO-NUMERO" (ej: "2024-1440")
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_reqctascanfrm(TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_reqctascanfrm(
    clave_cuenta TEXT
)
RETURNS TABLE (
    id_multa INTEGER,
    cuenta TEXT,
    axo_acta SMALLINT,
    num_acta INTEGER,
    fecha_acta DATE,
    fecha_recepcion DATE,
    fecha_cancelacion DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    num_licencia INTEGER,
    giro VARCHAR,
    dependencia SMALLINT,
    nombre_dependencia TEXT,
    expediente CHAR,
    calificacion NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    observacion TEXT,
    comentario VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_axo_acta SMALLINT;
    v_num_acta INTEGER;
    v_cuenta_search TEXT;
BEGIN
    -- Validar que el parámetro no sea NULL o vacío
    IF clave_cuenta IS NULL OR TRIM(clave_cuenta) = '' THEN
        RAISE EXCEPTION 'La clave de cuenta es requerida';
    END IF;

    -- Limpiar la entrada
    v_cuenta_search := TRIM(clave_cuenta);

    -- Si contiene guión, separar año y número
    IF POSITION('-' IN v_cuenta_search) > 0 THEN
        BEGIN
            v_axo_acta := CAST(SPLIT_PART(v_cuenta_search, '-', 1) AS SMALLINT);
            v_num_acta := CAST(SPLIT_PART(v_cuenta_search, '-', 2) AS INTEGER);
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION 'Formato de cuenta inválido. Use formato AÑO-NUMERO (ej: 2024-1440)';
        END;

        -- Buscar por año y número exactos
        RETURN QUERY
        SELECT
            m.id_multa,
            CONCAT(m.axo_acta, '-', m.num_acta)::TEXT AS cuenta,
            m.axo_acta,
            m.num_acta,
            m.fecha_acta,
            m.fecha_recepcion,
            m.fecha_cancelacion,
            m.contribuyente,
            m.domicilio,
            m.num_licencia,
            m.giro,
            m.id_dependencia AS dependencia,
            CASE m.id_dependencia
                WHEN 1 THEN 'TESORERIA'
                WHEN 3 THEN 'TRANSITO'
                WHEN 4 THEN 'MERCADOS'
                WHEN 5 THEN 'OBRAS PUBLICAS'
                WHEN 6 THEN 'DESARROLLO URBANO'
                WHEN 7 THEN 'REGLAMENTOS'
                WHEN 8 THEN 'RASTRO'
                WHEN 25 THEN 'ATENCION CIUDADANA'
                WHEN 35 THEN 'ECOLOGIA'
                ELSE 'OTRAS DEPENDENCIAS'
            END::TEXT AS nombre_dependencia,
            m.expediente,
            m.calificacion,
            m.multa,
            m.gastos,
            m.total,
            m.observacion,
            m.comentario
        FROM comun.multas m
        WHERE m.axo_acta = v_axo_acta
        AND m.num_acta = v_num_acta
        AND m.fecha_cancelacion IS NOT NULL
        ORDER BY m.fecha_cancelacion DESC
        LIMIT 100;
    ELSE
        -- Si no tiene guión, intentar buscar por número de acta solamente
        BEGIN
            v_num_acta := CAST(v_cuenta_search AS INTEGER);
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION 'Formato de cuenta inválido. Use formato AÑO-NUMERO (ej: 2024-1440) o solo el número de acta';
        END;

        RETURN QUERY
        SELECT
            m.id_multa,
            CONCAT(m.axo_acta, '-', m.num_acta)::TEXT AS cuenta,
            m.axo_acta,
            m.num_acta,
            m.fecha_acta,
            m.fecha_recepcion,
            m.fecha_cancelacion,
            m.contribuyente,
            m.domicilio,
            m.num_licencia,
            m.giro,
            m.id_dependencia AS dependencia,
            CASE m.id_dependencia
                WHEN 1 THEN 'TESORERIA'
                WHEN 3 THEN 'TRANSITO'
                WHEN 4 THEN 'MERCADOS'
                WHEN 5 THEN 'OBRAS PUBLICAS'
                WHEN 6 THEN 'DESARROLLO URBANO'
                WHEN 7 THEN 'REGLAMENTOS'
                WHEN 8 THEN 'RASTRO'
                WHEN 25 THEN 'ATENCION CIUDADANA'
                WHEN 35 THEN 'ECOLOGIA'
                ELSE 'OTRAS DEPENDENCIAS'
            END::TEXT AS nombre_dependencia,
            m.expediente,
            m.calificacion,
            m.multa,
            m.gastos,
            m.total,
            m.observacion,
            m.comentario
        FROM comun.multas m
        WHERE m.num_acta = v_num_acta
        AND m.fecha_cancelacion IS NOT NULL
        ORDER BY m.axo_acta DESC, m.fecha_cancelacion DESC
        LIMIT 100;
    END IF;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_reqctascanfrm(TEXT) IS 'Consulta de requerimientos de cuentas canceladas por clave de cuenta';
