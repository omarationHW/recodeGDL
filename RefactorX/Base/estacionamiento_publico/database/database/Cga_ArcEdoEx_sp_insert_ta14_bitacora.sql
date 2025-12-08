-- =============================================================================
-- STORED PROCEDURE: sp_insert_ta14_bitacora
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: Cga_ArcEdoEx / CargaEdoExPublicos.vue
-- Descripcion: Registra en bitacora la carga de una remesa
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_insert_ta14_bitacora(date, date, date, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_insert_ta14_bitacora(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_fecha DATE,
    p_num_rem INTEGER,
    p_cant_reg INTEGER
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_new_control INTEGER;
BEGIN
    -- Validar fechas requeridas
    IF p_fecha_inicio IS NULL OR p_fecha_fin IS NULL OR p_fecha IS NULL THEN
        RETURN QUERY SELECT false::boolean, 'Las fechas de inicio, fin y bitácora son requeridas'::text;
        RETURN;
    END IF;

    -- Validar rango de fechas
    IF p_fecha_inicio > p_fecha_fin THEN
        RETURN QUERY SELECT false::boolean, 'La fecha de inicio no puede ser mayor a la fecha fin'::text;
        RETURN;
    END IF;

    -- Obtener siguiente control
    SELECT COALESCE(MAX(control), 0) + 1 INTO v_new_control FROM public.ta14_bitacora;

    -- Insertar registro en bitácora (columnas reales: control, tipo, fecha_inicio, fecha_fin, fecha_hoy, num_remesa, cant_reg)
    INSERT INTO public.ta14_bitacora (
        control, tipo, fecha_inicio, fecha_fin, fecha_hoy, num_remesa, cant_reg
    ) VALUES (
        v_new_control,
        'A',
        p_fecha_inicio,
        p_fecha_fin,
        p_fecha,
        COALESCE(p_num_rem, 0),
        COALESCE(p_cant_reg, 0)
    );

    RETURN QUERY SELECT true::boolean, ('Bitácora registrada correctamente. Control: ' || v_new_control || ', Remesa: ' || COALESCE(p_num_rem, 0))::text;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false::boolean, ('Error al registrar en bitácora: ' || SQLERRM)::text;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
