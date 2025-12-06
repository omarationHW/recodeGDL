-- =====================================================
-- SP: sp_update_cuota_energia
-- Descripción: Actualiza solo el importe de una cuota existente
-- Parámetros:
--   p_id_kilowhatts: ID de la cuota a actualizar
--   p_importe: Nuevo importe
--   p_id_usuario: ID del usuario que modifica
-- Retorna: success (boolean), message (text)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_update_cuota_energia(INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_update_cuota_energia(
    p_id_kilowhatts INTEGER,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_axo INTEGER;
    v_periodo INTEGER;
BEGIN
    -- Validar parámetros obligatorios
    IF p_id_kilowhatts IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de cuota es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_importe IS NULL OR p_importe <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El importe debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    IF p_id_usuario IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de usuario es obligatorio'::TEXT;
        RETURN;
    END IF;

    -- Validar que exista el registro
    SELECT COUNT(*), MAX(axo), MAX(periodo)
    INTO v_exists, v_axo, v_periodo
    FROM public.ta_11_kilowhatts
    WHERE id_kilowhatts = p_id_kilowhatts;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'No se encontró la cuota con ID ' || p_id_kilowhatts::TEXT;
        RETURN;
    END IF;

    -- Actualizar solo el importe
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Cuota de energía actualizada correctamente (Año: ' || v_axo || ', Periodo: ' || v_periodo || ')'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_update_cuota_energia(INTEGER, NUMERIC, INTEGER) IS
'Actualiza el importe de una cuota de energía existente. Retorna success y message.';
