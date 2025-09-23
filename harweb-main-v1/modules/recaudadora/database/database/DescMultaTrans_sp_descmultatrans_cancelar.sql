-- Stored Procedure: sp_descmultatrans_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento de multa de transmisión patrimonial.
-- Generado para formulario: DescMultaTransFrm
-- Fecha: 2025-08-27 00:17:36

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