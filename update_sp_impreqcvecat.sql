-- Actualización del Stored Procedure para impreqCvecat
-- Retorna información completa del requerimiento generado

DROP FUNCTION IF EXISTS publico.recaudadora_impreqcvecat(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS publico.recaudadora_impreqcvecat(JSONB) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_impreqcvecat(
    p_clave_catastral VARCHAR
)
RETURNS TABLE (
    status VARCHAR,
    mensaje VARCHAR,
    folio_requerimiento VARCHAR,
    fecha_generacion DATE,
    propietario VARCHAR,
    direccion VARCHAR,
    monto_adeudo NUMERIC,
    clave_catastral VARCHAR,
    ejercicio VARCHAR,
    periodo VARCHAR,
    tipo_requerimiento VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_encontrado BOOLEAN;
    v_folio VARCHAR;
    v_ctarfc VARCHAR;
    v_importe NUMERIC;
    v_ejercicio VARCHAR;
BEGIN
    -- Validar que se proporcione la clave catastral
    IF p_clave_catastral IS NULL OR p_clave_catastral = '' THEN
        RETURN QUERY SELECT
            'error'::VARCHAR AS status,
            'Debe proporcionar una clave catastral'::VARCHAR AS mensaje,
            NULL::VARCHAR, NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
            NULL::NUMERIC, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR,
            NULL::VARCHAR, NULL::TEXT;
        RETURN;
    END IF;

    -- Buscar en req_400 por ctarfc (clave catastral)
    BEGIN
        SELECT
            r.folreq,
            r.ctarfc,
            CASE
                WHEN r.impcuo ~ '^[0-9]+$' THEN (r.impcuo::NUMERIC / 100)
                ELSE 0
            END,
            r.ejereq
        INTO v_folio, v_ctarfc, v_importe, v_ejercicio
        FROM req_400 r
        WHERE TRIM(r.ctarfc) ILIKE '%' || p_clave_catastral || '%'
        LIMIT 1;

        v_encontrado := FOUND;
    EXCEPTION
        WHEN OTHERS THEN
            v_encontrado := FALSE;
    END;

    -- Si se encontró el registro, retornar la información
    IF v_encontrado THEN
        RETURN QUERY SELECT
            'success'::VARCHAR AS status,
            'Requerimiento generado exitosamente'::VARCHAR AS mensaje,
            COALESCE(v_folio, 'SIN-FOLIO')::VARCHAR AS folio_requerimiento,
            CURRENT_DATE AS fecha_generacion,
            'CONTRIBUYENTE'::VARCHAR AS propietario,
            'DOMICILIO NO DISPONIBLE'::VARCHAR AS direccion,
            COALESCE(v_importe, 0)::NUMERIC AS monto_adeudo,
            COALESCE(v_ctarfc, p_clave_catastral)::VARCHAR AS clave_catastral,
            COALESCE(v_ejercicio, '0')::VARCHAR AS ejercicio,
            CASE
                WHEN v_ejercicio IS NOT NULL AND v_ejercicio != ''
                THEN 'Ejercicio ' || v_ejercicio
                ELSE 'Sin periodo definido'
            END::VARCHAR AS periodo,
            'Requerimiento de Pago'::VARCHAR AS tipo_requerimiento,
            'Requerimiento generado para clave catastral ' || p_clave_catastral::TEXT AS observaciones;
    ELSE
        -- No se encontró la clave catastral
        RETURN QUERY SELECT
            'error'::VARCHAR AS status,
            'No se encontró información para la clave catastral proporcionada'::VARCHAR AS mensaje,
            NULL::VARCHAR, NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
            NULL::NUMERIC, p_clave_catastral::VARCHAR, NULL::VARCHAR, NULL::VARCHAR,
            NULL::VARCHAR, NULL::TEXT;
    END IF;
END;
$$;

-- Comentarios sobre el mapeo:
-- req_400.ctarfc -> clave catastral buscada
-- req_400.folreq -> folio_requerimiento
-- req_400.impcuo -> monto_adeudo (dividido entre 100)
-- req_400.ejereq -> ejercicio
-- CURRENT_DATE -> fecha_generacion
-- Valores fijos para propietario y dirección (no disponibles en req_400)

-- Campos retornados:
-- status: 'success' o 'error'
-- mensaje: Descripción del resultado
-- folio_requerimiento: Folio del requerimiento
-- fecha_generacion: Fecha actual
-- propietario: Nombre del contribuyente
-- direccion: Domicilio del predio
-- monto_adeudo: Importe a pagar
-- clave_catastral: Clave catastral consultada
-- ejercicio: Año del ejercicio
-- periodo: Descripción del periodo
-- tipo_requerimiento: Tipo de documento
-- observaciones: Notas adicionales
