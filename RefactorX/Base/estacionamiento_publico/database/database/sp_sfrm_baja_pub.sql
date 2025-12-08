-- =============================================================================
-- STORED PROCEDURE: sp_sfrm_baja_pub
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: sfrm_baja_pub / BajasPublicos.vue
-- Descripcion: Procesa la baja de un estacionamiento publico
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_sfrm_baja_pub(varchar, text);

CREATE OR REPLACE FUNCTION public.sp_sfrm_baja_pub(
    p_numlic VARCHAR,
    p_motivo TEXT
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_id INTEGER;
    v_numlicencia INTEGER;
    v_folio_baja INTEGER;
    v_fecha_baja DATE;
BEGIN
    -- Validar parametros
    IF p_numlic IS NULL OR TRIM(p_numlic) = '' THEN
        RETURN QUERY SELECT false::boolean, 'Debe proporcionar el numero de licencia'::text;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT false::boolean, 'Debe proporcionar el motivo de la baja'::text;
        RETURN;
    END IF;

    -- Buscar la licencia en pubmain
    SELECT id, numlicencia, folio_baja, fecha_baja
    INTO v_id, v_numlicencia, v_folio_baja, v_fecha_baja
    FROM public.pubmain
    WHERE numlicencia = p_numlic::integer
    LIMIT 1;

    IF v_id IS NULL THEN
        RETURN QUERY SELECT false::boolean, ('No se encontro la licencia ' || p_numlic)::text;
        RETURN;
    END IF;

    -- Verificar si ya esta dada de baja
    IF v_fecha_baja IS NOT NULL THEN
        RETURN QUERY SELECT false::boolean, ('La licencia ' || p_numlic || ' ya esta dada de baja desde ' || v_fecha_baja::text)::text;
        RETURN;
    END IF;

    -- Generar folio de baja
    SELECT COALESCE(MAX(folio_baja), 0) + 1 INTO v_folio_baja FROM public.pubmain WHERE folio_baja IS NOT NULL;

    -- Actualizar registro con baja
    UPDATE public.pubmain
    SET folio_baja = v_folio_baja,
        fecha_baja = CURRENT_DATE,
        movto_cve = 'B'
    WHERE id = v_id;

    RETURN QUERY SELECT true::boolean, ('Baja registrada correctamente. Folio: ' || v_folio_baja || ', Licencia: ' || p_numlic)::text;
EXCEPTION
    WHEN invalid_text_representation THEN
        RETURN QUERY SELECT false::boolean, 'El numero de licencia debe ser numerico'::text;
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, ('Error: ' || SQLERRM)::text;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
