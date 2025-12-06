-- =====================================================
-- SP: sp_list_cuotas_energia
-- Descripción: Lista cuotas de energía con filtros opcionales
-- Parámetros:
--   p_axo: Año (NULL = todos)
--   p_periodo: Periodo (NULL = todos)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_list_cuotas_energia(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_list_cuotas_energia(
    p_axo INTEGER DEFAULT NULL,
    p_periodo INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_kilowhatts INTEGER,
    axo INTEGER,
    periodo INTEGER,
    importe NUMERIC(18,6),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo::INTEGER,
        k.periodo::INTEGER,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'SIN USUARIO')::VARCHAR(50) as usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_list_cuotas_energia(INTEGER, INTEGER) IS
'Lista cuotas de energía eléctrica con filtros opcionales por año y periodo. Incluye información del usuario.';


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
