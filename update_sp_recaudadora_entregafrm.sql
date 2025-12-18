-- Actualización del Stored Procedure para entregafrm
-- Usa la tabla entregas del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_entregafrm(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_entregafrm(datos TEXT)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio VARCHAR,
    ejecutor VARCHAR,
    fecha_entrega DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    v_datos JSON;
    v_folio VARCHAR;
    v_ejecutor VARCHAR;
    v_fecha DATE;
    v_tipo_entrega VARCHAR;
    v_destinatario VARCHAR;
    v_domicilio VARCHAR;
    v_clave_catastral VARCHAR;
    v_cuenta VARCHAR;
    v_rfc VARCHAR;
    v_concepto VARCHAR;
    v_motivo VARCHAR;
    v_monto DECIMAL;
    v_hora TIME;
    v_plazo VARCHAR;
    v_observaciones TEXT;
BEGIN
    -- Parsear el JSON
    BEGIN
        v_datos := datos::JSON;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, 'Error: JSON inválido'::TEXT, NULL::VARCHAR, NULL::VARCHAR, NULL::DATE;
            RETURN;
    END;

    -- Extraer campos del JSON
    v_tipo_entrega := v_datos->>'tipo_entrega';
    v_folio := v_datos->>'folio';
    v_ejecutor := v_datos->>'ejecutor';
    v_destinatario := v_datos->>'destinatario';
    v_domicilio := v_datos->>'domicilio';
    v_clave_catastral := v_datos->>'clave_catastral';
    v_cuenta := v_datos->>'cuenta';
    v_rfc := v_datos->>'rfc';
    v_concepto := v_datos->>'concepto';
    v_motivo := v_datos->>'motivo';
    v_monto := (v_datos->>'monto')::DECIMAL;
    v_fecha := (v_datos->>'fecha_entrega')::DATE;
    v_hora := (v_datos->>'hora_entrega')::TIME;
    v_plazo := v_datos->>'plazo_pago';
    v_observaciones := v_datos->>'observaciones';

    -- Validaciones básicas
    IF v_folio IS NULL OR v_folio = '' THEN
        RETURN QUERY SELECT FALSE, 'Error: El folio es obligatorio'::TEXT, NULL::VARCHAR, NULL::VARCHAR, NULL::DATE;
        RETURN;
    END IF;

    IF v_ejecutor IS NULL OR v_ejecutor = '' THEN
        RETURN QUERY SELECT FALSE, 'Error: El ejecutor es obligatorio'::TEXT, NULL::VARCHAR, NULL::VARCHAR, NULL::DATE;
        RETURN;
    END IF;

    -- Verificar si el folio ya existe (ahora busca en public.entregas)
    IF EXISTS (SELECT 1 FROM public.entregas e WHERE e.folio = v_folio) THEN
        RETURN QUERY SELECT FALSE, 'Error: El folio ya existe'::TEXT, v_folio, NULL::VARCHAR, NULL::DATE;
        RETURN;
    END IF;

    -- Insertar la entrega (ahora en public.entregas)
    BEGIN
        INSERT INTO public.entregas (
            tipo_entrega, folio, ejecutor, destinatario, domicilio,
            clave_catastral, cuenta, rfc, concepto, motivo,
            monto, fecha_entrega, hora_entrega, plazo_pago,
            observaciones, datos_json
        ) VALUES (
            v_tipo_entrega, v_folio, v_ejecutor, v_destinatario, v_domicilio,
            v_clave_catastral, v_cuenta, v_rfc, v_concepto, v_motivo,
            v_monto, v_fecha, v_hora, v_plazo,
            v_observaciones, datos
        );

        -- Retornar éxito
        RETURN QUERY SELECT
            TRUE,
            'Entrega registrada exitosamente'::TEXT,
            v_folio,
            v_ejecutor,
            v_fecha;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, ('Error al guardar: ' || SQLERRM)::TEXT, NULL::VARCHAR, NULL::VARCHAR, NULL::DATE;
            RETURN;
    END;
END;
$$;

-- Comentarios sobre el stored procedure:
-- Este SP recibe un JSON con los datos de una entrega y los registra en la tabla public.entregas
-- Campos del JSON esperados:
--   - tipo_entrega: Tipo de entrega (requerimiento, notificación, etc.)
--   - folio: Folio único del documento entregado (obligatorio)
--   - ejecutor: Nombre del ejecutor (obligatorio)
--   - destinatario: Persona que recibió
--   - domicilio: Domicilio donde se entregó
--   - clave_catastral: Clave catastral relacionada
--   - cuenta: Número de cuenta relacionada
--   - rfc: RFC del destinatario
--   - concepto: Concepto de la entrega
--   - motivo: Motivo de la entrega
--   - monto: Monto del adeudo
--   - fecha_entrega: Fecha de la entrega
--   - hora_entrega: Hora de la entrega
--   - plazo_pago: Plazo para pagar
--   - observaciones: Observaciones adicionales
