-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_UP_PAGOS (EXACTO del archivo original)
-- Archivo: 44_SP_ESTACIONAMIENTOS_SFRM_UP_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_up_pagos_update
-- Tipo: CRUD
-- Descripción: Actualiza la tabla ta_14_folios con la fecha de baja y pago, y marca el movimiento como 'R'. Devuelve éxito o error.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_up_pagos_update(
    p_alo integer,
    p_folio integer,
    p_fecbaj date
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
    UPDATE public.ta_14_folios
    SET fecha_baja = p_fecbaj,
        cve_mov = 'R',
        fecha_pago = p_fecbaj
    WHERE aso = p_alo AND folio = p_folio;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Actualización exitosa';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el registro para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

