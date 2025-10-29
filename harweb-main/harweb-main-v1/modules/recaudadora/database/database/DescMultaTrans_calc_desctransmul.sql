-- Stored Procedure: calc_desctransmul
-- Tipo: CRUD
-- Descripción: Calcula y aplica el descuento de multa de transmisión patrimonial. Actualiza los importes y recalcula si es necesario.
-- Generado para formulario: DescMultaTransFrm
-- Fecha: 2025-08-27 00:17:36

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