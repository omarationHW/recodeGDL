-- =============================================
-- Stored Procedure: sp_sfrm_baja_pub
-- Descripción: Procesa la baja de un estacionamiento público
-- Uso: BajasPublicos.vue (línea 42)
-- Parámetros:
--   numlic: Número de licencia a dar de baja
--   motivo: Motivo de la baja
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_sfrm_baja_pub(
    p_numlic VARCHAR(50),
    p_motivo TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR(255),
    folio_baja INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_estado VARCHAR(1);
    v_folio_baja INTEGER;
    v_success BOOLEAN := FALSE;
    v_message VARCHAR(255) := '';
BEGIN
    -- Validar que se proporcione número de licencia
    IF p_numlic IS NULL OR TRIM(p_numlic) = '' THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un número de licencia'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que se proporcione motivo
    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un motivo de baja'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Buscar la licencia
    SELECT id, movto_cve
    INTO v_id, v_estado
    FROM pubmain
    WHERE numlicencia = CAST(p_numlic AS INTEGER)
    LIMIT 1;

    -- Verificar si existe
    IF v_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar si ya está cancelada
    IF v_estado = 'C' THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está dada de baja'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Generar folio de baja (obtener el siguiente folio disponible)
    SELECT COALESCE(MAX(folio_baja), 0) + 1
    INTO v_folio_baja
    FROM pubmain
    WHERE folio_baja IS NOT NULL;

    -- Actualizar el registro marcándolo como cancelado
    UPDATE pubmain
    SET
        movto_cve = 'C',  -- C = Cancelado/Baja
        fecha_baja = CURRENT_DATE,
        folio_baja = v_folio_baja,
        observaciones = COALESCE(observaciones || ' | ', '') ||
                       'BAJA: ' || p_motivo || ' (Fecha: ' || CURRENT_DATE::TEXT || ')'
    WHERE id = v_id;

    -- Registrar en bitácora/auditoría si existe tabla de auditoría
    BEGIN
        INSERT INTO auditoria_estacionamientos (
            tabla,
            operacion,
            id_registro,
            usuario,
            fecha,
            descripcion
        ) VALUES (
            'pubmain',
            'BAJA',
            v_id,
            CURRENT_USER,
            NOW(),
            'Baja de estacionamiento público. Licencia: ' || p_numlic ||
            '. Motivo: ' || p_motivo || '. Folio baja: ' || v_folio_baja
        );
    EXCEPTION
        WHEN undefined_table THEN
            -- Si no existe tabla de auditoría, continuar sin error
            NULL;
    END;

    v_success := TRUE;
    v_message := 'Baja registrada correctamente. Folio: ' || v_folio_baja;

    RETURN QUERY SELECT v_success, v_message, v_folio_baja;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al procesar la baja: ' || SQLERRM,
            NULL::INTEGER;
END;
$$;

-- Comentarios y metadatos
COMMENT ON FUNCTION public.sp_sfrm_baja_pub(VARCHAR, TEXT) IS
'SP que procesa la baja de un estacionamiento público.
Marca el registro como cancelado (movto_cve = C), genera folio de baja y registra en auditoría.
Usado por: BajasPublicos.vue';
