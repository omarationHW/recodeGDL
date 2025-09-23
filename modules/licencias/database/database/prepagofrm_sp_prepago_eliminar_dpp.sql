-- Stored Procedure: sp_prepago_eliminar_dpp
-- Tipo: CRUD
-- Descripción: Elimina el descuento pronto pago para la cuenta.
-- Generado para formulario: prepagofrm
-- Fecha: 2025-08-27 18:51:25

CREATE OR REPLACE FUNCTION sp_prepago_eliminar_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de eliminación (actualiza tablas, etc)
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;