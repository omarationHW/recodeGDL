-- =============================================================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_up_pagos (UpPagosPublicos.vue)
-- Base: estacionamiento_publico
-- Esquema: public
-- Total SPs: 1
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SP: sp_up_pagos_update
-- Descripción: Actualiza la tabla ta_14_folios con la fecha de baja y pago,
--              y marca el movimiento como 'R' (Regularizado)
-- Parámetros:
--   p_alo: Año del folio
--   p_folio: Número de folio
--   p_fecbaj: Nueva fecha de baja/pago
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_up_pagos_update(integer, integer, date);

CREATE OR REPLACE FUNCTION public.sp_up_pagos_update(
    p_alo integer,
    p_folio integer,
    p_fecbaj date
) RETURNS TABLE(success boolean, message text) AS $func$
BEGIN
    UPDATE public.ta_14_folios
    SET fecha_baja = p_fecbaj,
        cve_mov = 'R',
        fecha_pago = p_fecbaj
    WHERE aso = p_alo AND folio = p_folio;

    IF FOUND THEN
        RETURN QUERY SELECT true::boolean,
            'Actualización exitosa: Folio ' || p_folio || ' del año ' || p_alo || ' actualizado con fecha ' || p_fecbaj::text;
    ELSE
        RETURN QUERY SELECT false::boolean,
            'No se encontró el folio ' || p_folio || ' del año ' || p_alo;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, 'Error: ' || SQLERRM;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURES
-- =============================================================================
