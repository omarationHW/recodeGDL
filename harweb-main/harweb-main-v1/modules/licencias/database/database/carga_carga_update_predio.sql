-- Stored Procedure: carga_update_predio
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un predio.
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_update_predio(p_cvecuenta INTEGER, p_data JSON)
RETURNS JSON AS $$
BEGIN
    UPDATE convcta SET
        cvecatnva = p_data->>'cvecatnva',
        subpredio = (p_data->>'subpredio')::INTEGER
        -- ... otros campos
    WHERE cvecuenta = p_cvecuenta;
    RETURN json_build_object('cvecuenta', p_cvecuenta, 'status', 'updated');
END;
$$ LANGUAGE plpgsql;