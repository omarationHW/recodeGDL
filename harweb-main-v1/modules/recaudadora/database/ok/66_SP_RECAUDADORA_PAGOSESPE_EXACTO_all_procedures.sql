-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGOSESPE (EXACTO del archivo original)
-- Archivo: 66_SP_RECAUDADORA_PAGOSESPE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_autpagoesp_list
-- Tipo: Report
-- Descripción: Lista los pagos especiales autorizados para una cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autpagoesp_list(p_cvecuenta integer)
RETURNS TABLE(
    cveaut integer,
    bimini smallint,
    axoini smallint,
    bimfin smallint,
    axofin smallint,
    fecaut date,
    autorizo varchar,
    cvecuenta integer,
    cvepago integer
) AS $$
BEGIN
    RETURN QUERY SELECT cveaut, bimini, axoini, bimfin, axofin, fecaut, autorizo, cvecuenta, cvepago
    FROM autpagoesp WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGOSESPE (EXACTO del archivo original)
-- Archivo: 66_SP_RECAUDADORA_PAGOSESPE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_autpagoesp_cancel
-- Tipo: CRUD
-- Descripción: Cancela un pago especial autorizado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autpagoesp_cancel(p_cveaut integer, p_autorizo varchar)
RETURNS void AS $$
DECLARE
    v_pago record;
BEGIN
    SELECT * INTO v_pago FROM autpagoesp WHERE cveaut = p_cveaut;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Registro no encontrado';
    END IF;
    IF v_pago.cvepago = 999999 THEN
        RAISE EXCEPTION 'El pago autorizado ya está cancelado...';
    END IF;
    IF v_pago.cvepago IS NOT NULL AND v_pago.cvepago <> 999999 THEN
        RAISE EXCEPTION 'El pago autorizado seleccionado se encuentra pagado, no puedes cancelar...';
    END IF;
    UPDATE autpagoesp SET cvepago = 999999, fecaut = CURRENT_DATE, autorizo = p_autorizo WHERE cveaut = p_cveaut;
END;
$$ LANGUAGE plpgsql;

-- ============================================

