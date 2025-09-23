-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DescMultaTransFrm
-- Generado: 2025-08-27 00:17:36
-- Total SPs: 3
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

-- SP 2/3: sp_descmultatrans_alta
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de descuento de multa de transmisión patrimonial.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_descmultatrans_alta(
    IN p_folio INTEGER,
    IN p_porcentaje FLOAT,
    IN p_captalta VARCHAR(50),
    IN p_autoriza INTEGER,
    IN p_observaciones VARCHAR(250)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO descmultatrans (folio, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, autoriza, observaciones)
    VALUES (p_folio, p_porcentaje, CURRENT_DATE, p_captalta, NULL, NULL, 'V', NULL, p_autoriza, p_observaciones);
END;
$$;

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

