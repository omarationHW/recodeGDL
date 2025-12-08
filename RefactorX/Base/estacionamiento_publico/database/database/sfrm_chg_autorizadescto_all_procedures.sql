-- =============================================================================
-- STORED PROCEDURES: Autorizacion de Descuentos
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: sfrm_chg_autorizadescto / ChgAutorizDesctoPublicos.vue
-- Descripcion: Consulta historica y cambio de autorizacion a Tesorero
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SP 1/2: sp_buscar_folios_histo
-- Busca folios en historial por placa
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_buscar_folios_histo(varchar);

CREATE OR REPLACE FUNCTION public.sp_buscar_folios_histo(
    p_placa VARCHAR
) RETURNS TABLE (
    axo smallint,
    folio integer,
    placa varchar,
    fecha_folio date
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        h.axo,
        h.folio,
        TRIM(h.placa)::varchar as placa,
        h.fecha_folio
    FROM public.ta14_folios_histo h
    WHERE TRIM(h.placa) = UPPER(TRIM(p_placa))
    ORDER BY h.axo DESC, h.folio DESC
    LIMIT 100;
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP 2/2: sp_cambiar_a_tesorero
-- Actualiza obs a 'Tesorero' en ta14_folios_free
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_cambiar_a_tesorero(integer, integer);

CREATE OR REPLACE FUNCTION public.sp_cambiar_a_tesorero(
    p_axo INTEGER,
    p_folio INTEGER
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_affected integer;
BEGIN
    -- Verificar si existe en ta14_folios_free
    IF NOT EXISTS (SELECT 1 FROM public.ta14_folios_free WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT false::boolean,
            'No se encontro registro de descuento para folio ' || p_folio || ' del anio ' || p_axo;
        RETURN;
    END IF;

    -- Actualizar obs a Tesorero
    UPDATE public.ta14_folios_free
    SET obs = 'Tesorero'
    WHERE axo = p_axo AND folio = p_folio;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected > 0 THEN
        RETURN QUERY SELECT true::boolean,
            'Autorizacion cambiada a Tesorero para folio ' || p_folio || ' del anio ' || p_axo;
    ELSE
        RETURN QUERY SELECT false::boolean,
            'No se pudo actualizar el registro';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, 'Error: ' || SQLERRM;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURES
-- =============================================================================
