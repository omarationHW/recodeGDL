-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCMULTATRANSFRM (EXACTO del archivo original)
-- Archivo: 50_SP_RECAUDADORA_DESCMULTATRANSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: calc_desctransmul
-- Tipo: CRUD
-- Descripción: Calcula y aplica el descuento de multa de transmisión patrimonial. Actualiza los importes y recalcula si es necesario.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE calc_desctransmul(IN par_folio INTEGER, IN par_Opc INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- par_Opc: 1 = aplicar descuento, 2 = cancelar descuento
    IF par_Opc = 1 THEN
        -- Actualiza los importes de la multa con el descuento
        UPDATE impuestoTransp SET multaimpuesto = multaimpuesto - (
            SELECT porcentaje FROM descmultatrans WHERE folio = par_folio AND estado = 'V' ORDER BY id_descmultatrans DESC LIMIT 1
        ) * multaimpuesto / 100
        WHERE folio = par_folio;
    ELSIF par_Opc = 2 THEN
        -- Cancela el descuento (restaura importe original)
        UPDATE impuestoTransp SET multaimpuesto = (
            SELECT multaimpuesto FROM impuestoTransp_backup WHERE folio = par_folio
        )
        WHERE folio = par_folio;
    END IF;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCMULTATRANSFRM (EXACTO del archivo original)
-- Archivo: 50_SP_RECAUDADORA_DESCMULTATRANSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_descmultatrans_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento de multa de transmisión patrimonial.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_descmultatrans_cancelar(
    IN p_id_descmultatrans INTEGER,
    IN p_folio INTEGER,
    IN p_captbaja VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE descmultatrans
    SET estado = 'C', fecbaja = CURRENT_DATE, captbaja = p_captbaja
    WHERE folio = p_folio AND id_descmultatrans = p_id_descmultatrans;
END;
$$;

-- ============================================

