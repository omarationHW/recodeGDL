-- Stored Procedure: sp_get_public_parking_debts
-- Tipo: Report
-- Descripción: Obtiene los adeudos de un estacionamiento público por su ID.
-- Generado para formulario: sfrm_consultapublicos
-- Fecha: 2025-08-27 16:04:06

CREATE OR REPLACE FUNCTION sp_get_public_parking_debts(pubid integer)
RETURNS TABLE (
    concepto varchar(50),
    axo integer,
    mes integer,
    adeudo numeric(12,2),
    recargos numeric(12,2)
) AS $$
BEGIN
    -- Aquí debe ir la lógica de cálculo de adeudos, por ejemplo:
    RETURN QUERY
    SELECT concepto, axo, mes, adeudo, recargos
    FROM cajero_pub_detalle(3, pubid, 0, 0);
END;
$$ LANGUAGE plpgsql;