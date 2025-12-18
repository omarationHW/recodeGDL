-- Corrección del Stored Procedure para firma electrónica
-- Usa la tabla firmas_electronicas que YA EXISTE en el esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_firma_electronica(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_firma_electronica(datos TEXT)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio VARCHAR,
    fecha_firma TIMESTAMP,
    usuario VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    v_datos JSON;
    v_folio VARCHAR;
    v_usuario VARCHAR;
    v_tipo VARCHAR;
    v_datos_firma TEXT;
    v_hash VARCHAR;
    v_fecha TIMESTAMP;
    v_ip VARCHAR;
    v_dispositivo VARCHAR;
    v_observaciones TEXT;
BEGIN
    -- Parsear el JSON
    BEGIN
        v_datos := datos::JSON;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, 'Error: JSON inválido'::TEXT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR;
            RETURN;
    END;

    -- Extraer campos del JSON
    v_folio := v_datos->>'folio';
    v_usuario := v_datos->>'usuario';
    v_tipo := v_datos->>'tipo';
    v_datos_firma := v_datos->>'datos_firma';
    v_ip := v_datos->>'ip_address';
    v_dispositivo := v_datos->>'dispositivo';
    v_observaciones := v_datos->>'observaciones';

    -- Validaciones básicas
    IF v_folio IS NULL OR v_folio = '' THEN
        RETURN QUERY SELECT FALSE, 'Error: El folio es obligatorio'::TEXT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR;
        RETURN;
    END IF;

    IF v_usuario IS NULL OR v_usuario = '' THEN
        RETURN QUERY SELECT FALSE, 'Error: El usuario es obligatorio'::TEXT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si el folio ya tiene firma (CORREGIDO: ahora busca en public.firmas_electronicas)
    IF EXISTS (SELECT 1 FROM public.firmas_electronicas fe WHERE fe.folio = v_folio) THEN
        RETURN QUERY SELECT FALSE, 'Error: Este folio ya cuenta con firma electrónica'::TEXT, v_folio, NULL::TIMESTAMP, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Generar hash con md5
    v_hash := md5(v_folio || v_usuario || NOW()::TEXT || COALESCE(v_datos_firma, ''));
    v_fecha := NOW();

    -- Insertar la firma (CORREGIDO: ahora en public.firmas_electronicas)
    BEGIN
        INSERT INTO public.firmas_electronicas (
            folio, usuario, tipo, datos_firma, hash_firma, fecha_firma,
            datos_json, ip_address, dispositivo, observaciones
        ) VALUES (
            v_folio, v_usuario, v_tipo, v_datos_firma, v_hash, v_fecha,
            datos, v_ip, v_dispositivo, v_observaciones
        );

        -- Retornar éxito
        RETURN QUERY SELECT
            TRUE,
            'Firma electrónica registrada exitosamente'::TEXT,
            v_folio,
            v_fecha,
            v_usuario;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, ('Error al guardar firma: ' || SQLERRM)::TEXT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR;
            RETURN;
    END;
END;
$$;

COMMENT ON FUNCTION publico.recaudadora_firma_electronica(TEXT) IS 'Registra firmas electrónicas en public.firmas_electronicas';
