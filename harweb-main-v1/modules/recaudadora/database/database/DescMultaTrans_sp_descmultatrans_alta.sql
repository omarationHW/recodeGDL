-- Stored Procedure: sp_descmultatrans_alta
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de descuento de multa de transmisión patrimonial.
-- Generado para formulario: DescMultaTransFrm
-- Fecha: 2025-08-27 00:17:36

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