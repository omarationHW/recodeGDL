-- Stored Procedure: carga_delete_predio
-- Tipo: CRUD
-- Descripción: Elimina un predio por cuenta.
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_delete_predio(p_cvecuenta INTEGER)
RETURNS JSON AS $$
BEGIN
    DELETE FROM convcta WHERE cvecuenta = p_cvecuenta;
    RETURN json_build_object('cvecuenta', p_cvecuenta, 'status', 'deleted');
END;
$$ LANGUAGE plpgsql;