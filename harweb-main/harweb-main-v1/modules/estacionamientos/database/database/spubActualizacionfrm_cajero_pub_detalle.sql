-- Stored Procedure: cajero_pub_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un estacionamiento
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE FUNCTION cajero_pub_detalle(
    p_opc integer,
    p_pubid integer,
    p_axo integer,
    p_mes integer
) RETURNS TABLE(concepto varchar, axo integer, mes integer, adeudo numeric, recargos numeric) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, adeudo, recargos
    FROM pubadeudo
    WHERE pubmain_id = p_pubid;
END;
$$ LANGUAGE plpgsql;