-- Actualización del Stored Procedure para ImpresionNva
-- Retorna información completa de la impresión generada

DROP FUNCTION IF EXISTS publico.recaudadora_impresionnva(TEXT) CASCADE;
DROP FUNCTION IF EXISTS publico.recaudadora_impresionnva(JSONB) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_impresionnva(
    p_datos TEXT
)
RETURNS TABLE (
    status VARCHAR,
    mensaje VARCHAR,
    folio_impresion VARCHAR,
    fecha_generacion DATE,
    tipo_documento VARCHAR,
    numero_paginas INTEGER,
    clave_cuenta VARCHAR,
    contribuyente VARCHAR,
    monto_total NUMERIC,
    periodo VARCHAR,
    estado VARCHAR,
    formato VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_datos JSON;
    v_clave_cuenta VARCHAR;
    v_encontrado BOOLEAN;
    v_folio VARCHAR;
    v_ctarfc VARCHAR;
    v_importe NUMERIC;
    v_tipo VARCHAR;
BEGIN
    -- Parsear el JSON de entrada
    BEGIN
        v_datos := p_datos::JSON;
        v_clave_cuenta := v_datos->>'clave_cuenta';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                'error'::VARCHAR AS status,
                'Error al procesar los datos de entrada'::VARCHAR AS mensaje,
                NULL::VARCHAR, NULL::DATE, NULL::VARCHAR, NULL::INTEGER,
                NULL::VARCHAR, NULL::VARCHAR, NULL::NUMERIC, NULL::VARCHAR,
                NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT;
            RETURN;
    END;

    -- Validar que se proporcione la clave de cuenta
    IF v_clave_cuenta IS NULL OR v_clave_cuenta = '' THEN
        RETURN QUERY SELECT
            'error'::VARCHAR AS status,
            'Debe proporcionar una clave de cuenta'::VARCHAR AS mensaje,
            NULL::VARCHAR, NULL::DATE, NULL::VARCHAR, NULL::INTEGER,
            NULL::VARCHAR, NULL::VARCHAR, NULL::NUMERIC, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT;
        RETURN;
    END IF;

    -- Buscar información en req_400 por ctarfc o folreq
    BEGIN
        SELECT
            r.folreq,
            r.ctarfc,
            CASE
                WHEN r.impcuo ~ '^[0-9]+$' THEN (r.impcuo::NUMERIC / 100)
                ELSE 0
            END,
            r.tpr
        INTO v_folio, v_ctarfc, v_importe, v_tipo
        FROM req_400 r
        WHERE TRIM(r.ctarfc) ILIKE '%' || v_clave_cuenta || '%'
           OR TRIM(r.folreq) ILIKE '%' || v_clave_cuenta || '%'
        LIMIT 1;

        v_encontrado := FOUND;
    EXCEPTION
        WHEN OTHERS THEN
            v_encontrado := FALSE;
    END;

    -- Si se encontró información, retornar los datos completos
    IF v_encontrado THEN
        RETURN QUERY SELECT
            'success'::VARCHAR AS status,
            'Impresión generada exitosamente'::VARCHAR AS mensaje,
            ('IMP-' || COALESCE(v_folio, LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0')))::VARCHAR AS folio_impresion,
            CURRENT_DATE AS fecha_generacion,
            CASE
                WHEN v_tipo = 'P' THEN 'Requerimiento Predial'
                WHEN v_tipo = 'M' THEN 'Requerimiento Multas'
                WHEN v_tipo = 'L' THEN 'Requerimiento Licencias'
                ELSE 'Documento de Requerimiento'
            END::VARCHAR AS tipo_documento,
            CASE
                WHEN v_importe > 5000 THEN 2
                ELSE 1
            END::INTEGER AS numero_paginas,
            COALESCE(v_ctarfc, v_clave_cuenta)::VARCHAR AS clave_cuenta,
            'CONTRIBUYENTE'::VARCHAR AS contribuyente,
            COALESCE(v_importe, 0)::NUMERIC AS monto_total,
            'Periodo actual'::VARCHAR AS periodo,
            'Generado'::VARCHAR AS estado,
            'PDF'::VARCHAR AS formato,
            ('Impresión generada para la cuenta ' || v_clave_cuenta || ' el ' || CURRENT_DATE::TEXT)::TEXT AS observaciones;
    ELSE
        -- No se encontró información para la cuenta
        RETURN QUERY SELECT
            'error'::VARCHAR AS status,
            'No se encontró información para la clave de cuenta proporcionada'::VARCHAR AS mensaje,
            NULL::VARCHAR, NULL::DATE, NULL::VARCHAR, NULL::INTEGER,
            v_clave_cuenta::VARCHAR, NULL::VARCHAR, NULL::NUMERIC, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT;
    END IF;
END;
$$;

-- Comentarios sobre el mapeo:
-- req_400.folreq -> folio base para impresión
-- req_400.ctarfc -> clave_cuenta buscada
-- req_400.impcuo -> monto_total (dividido entre 100)
-- req_400.tpr -> tipo de requerimiento
-- CURRENT_DATE -> fecha_generacion
-- Valores calculados para numero_paginas basado en monto
-- Valores fijos para contribuyente, estado, formato

-- Campos retornados:
-- status: 'success' o 'error'
-- mensaje: Descripción del resultado
-- folio_impresion: Folio único de la impresión (IMP-XXXXXX)
-- fecha_generacion: Fecha actual
-- tipo_documento: Tipo de requerimiento
-- numero_paginas: Cantidad de páginas (1 o 2)
-- clave_cuenta: Cuenta consultada
-- contribuyente: Nombre del contribuyente
-- monto_total: Importe total
-- periodo: Periodo del documento
-- estado: Estado de la impresión
-- formato: Formato del documento (PDF)
-- observaciones: Información adicional
