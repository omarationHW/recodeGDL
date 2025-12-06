-- =====================================================
-- SP: sp_insert_cuota_energia
-- Descripción: Inserta nueva cuota de energía con validaciones
-- Parámetros:
--   p_axo: Año
--   p_periodo: Periodo
--   p_importe: Importe de la cuota
--   p_id_usuario: ID del usuario que registra
-- Retorna: success (boolean), message (text), id_kilowhatts (integer)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_insert_cuota_energia(INTEGER, INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_insert_cuota_energia(
    p_axo INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_kilowhatts INTEGER
) AS $$
DECLARE
    v_exists INTEGER;
    v_new_id INTEGER;
BEGIN
    -- Validar parámetros obligatorios
    IF p_axo IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El año es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_periodo IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El periodo es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_importe IS NULL OR p_importe <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El importe debe ser mayor a cero'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_id_usuario IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de usuario es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista ya esa combinación axo+periodo
    SELECT COUNT(*) INTO v_exists
    FROM public.ta_11_kilowhatts
    WHERE axo = p_axo AND periodo = p_periodo;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe una cuota registrada para el año ' || p_axo || ' y periodo ' || p_periodo::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar la nueva cuota
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, NOW(), p_id_usuario)
    RETURNING public.ta_11_kilowhatts.id_kilowhatts INTO v_new_id;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Cuota de energía registrada correctamente'::TEXT,
        v_new_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_insert_cuota_energia(INTEGER, INTEGER, NUMERIC, INTEGER) IS
'Inserta nueva cuota de energía con validaciones. Retorna success, message y id_kilowhatts generado.';
