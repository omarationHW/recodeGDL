-- =============================================================================
-- STORED PROCEDURE: sp_up_pagos_update
-- Base: estacionamiento_publico
-- Esquema: public
-- Descripción: Actualiza la fecha de pago de un folio en ta14_fol_banorte
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_up_pagos_update(integer, integer, date);

CREATE OR REPLACE FUNCTION public.sp_up_pagos_update(
    p_alo integer,
    p_folio integer,
    p_fecbaj date
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_affected integer;
BEGIN
    -- Actualizar fecha de pago en ta14_fol_banorte
    UPDATE public.ta14_fol_banorte
    SET fec_pago = p_fecbaj,
        status_mpio = 1,  -- Marcado como pagado
        fecha_afectacion = CURRENT_DATE
    WHERE axo = p_alo AND folio = p_folio;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected > 0 THEN
        RETURN QUERY SELECT true::boolean,
            'Actualización exitosa: Folio ' || p_folio || ' del año ' || p_alo || ' actualizado con fecha de pago ' || p_fecbaj::text || ' (' || v_affected || ' registro(s) afectados)';
    ELSE
        -- Verificar si el folio existe
        IF EXISTS (SELECT 1 FROM public.ta14_fol_banorte WHERE axo = p_alo AND folio = p_folio) THEN
            RETURN QUERY SELECT false::boolean,
                'El folio ' || p_folio || ' del año ' || p_alo || ' ya tiene fecha de pago asignada';
        ELSE
            RETURN QUERY SELECT false::boolean,
                'No se encontró el folio ' || p_folio || ' del año ' || p_alo || ' en la base de datos';
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, 'Error: ' || SQLERRM;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
