-- Stored Procedure: carga_save_predio
-- Tipo: CRUD
-- Descripción: Guarda un nuevo predio (alta).
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_save_predio(p_data JSON)
RETURNS JSON AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Extraer datos y guardar (ejemplo)
    INSERT INTO convcta (cvecatnva, subpredio, ...) VALUES (
        p_data->>'cvecatnva',
        (p_data->>'subpredio')::INTEGER
        -- ... otros campos
    ) RETURNING cvecuenta INTO v_cvecuenta;
    RETURN json_build_object('cvecuenta', v_cvecuenta, 'status', 'created');
END;
$$ LANGUAGE plpgsql;