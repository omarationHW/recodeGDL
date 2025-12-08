-- =============================================================================
-- STORED PROCEDURE: sp_aplica_pago_divadmin
-- Base: estacionamiento_publico
-- Esquema: public
-- Descripcion: Aplica pago a folio de adeudo (Diversos Admin)
--   - Actualiza estado en ta14_folios_adeudo a 14 (pagado)
--   - Inserta registro en ta14_folios_histo para historial
-- Formulario: AplicaPgo_DivAdmin
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_aplica_pago_divadmin(integer, integer, date, integer, varchar, integer, varchar);

CREATE OR REPLACE FUNCTION public.sp_aplica_pago_divadmin(
    p_axo INTEGER,
    p_folio INTEGER,
    p_fecha DATE,
    p_reca INTEGER,
    p_caja VARCHAR,
    p_oper INTEGER,
    p_usuario VARCHAR
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_control integer;
    v_placa varchar;
    v_fecha_folio date;
    v_infraccion smallint;
    v_vigilante integer;
    v_estado_actual smallint;
    v_zona smallint;
    v_espacio smallint;
BEGIN
    -- Verificar que existe y no esta pagado
    SELECT estado, placa, fecha_folio, infraccion, vigilante, zona, espacio
    INTO v_estado_actual, v_placa, v_fecha_folio, v_infraccion, v_vigilante, v_zona, v_espacio
    FROM public.ta14_folios_adeudo
    WHERE axo = p_axo AND folio = p_folio;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false::boolean, 'No se encontro el folio ' || p_folio || ' del anio ' || p_axo;
        RETURN;
    END IF;

    IF v_estado_actual IN (2, 14) THEN
        RETURN QUERY SELECT false::boolean, 'El folio ' || p_folio || ' ya esta pagado (estado: ' || v_estado_actual || ')';
        RETURN;
    END IF;

    -- Obtener siguiente control para historial
    SELECT COALESCE(MAX(control), 0) + 1 INTO v_control FROM public.ta14_folios_histo;

    -- Insertar en historial
    INSERT INTO public.ta14_folios_histo (
        control, fecha_movto, axo, folio, fecha_folio, placa, infraccion, estado,
        vigilante, fec_cap, usu_inicial, codigo_movto, zona, espacio
    ) VALUES (
        v_control, p_fecha, p_axo, p_folio, v_fecha_folio, v_placa, v_infraccion, 14,
        v_vigilante, CURRENT_DATE, COALESCE(p_oper, 0), 2, v_zona, v_espacio
    );

    -- Actualizar estado en tabla principal
    UPDATE public.ta14_folios_adeudo
    SET estado = 14  -- 14 = Pagado
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT true::boolean, 'Pago aplicado correctamente al folio ' || p_folio || ' del anio ' || p_axo;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, 'Error: ' || SQLERRM;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
