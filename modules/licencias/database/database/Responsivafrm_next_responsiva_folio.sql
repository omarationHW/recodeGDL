-- Stored Procedure: next_responsiva_folio
-- Tipo: CRUD
-- Descripción: Obtiene el siguiente folio para responsiva o supervision y actualiza el consecutivo.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-26 18:03:33

CREATE OR REPLACE FUNCTION next_responsiva_folio(tipo_in TEXT, axo_in INTEGER) RETURNS INTEGER AS $$
DECLARE
    folio INTEGER;
    param_col TEXT;
BEGIN
    IF tipo_in = 'R' THEN
        param_col := 'responsiva';
    ELSE
        param_col := 'supervision';
    END IF;
    -- Se asume que hay una tabla parametros_lic con columnas 'responsiva' y 'supervision'
    EXECUTE format('SELECT %I FROM parametros_lic', param_col) INTO folio;
    folio := folio + 1;
    EXECUTE format('UPDATE parametros_lic SET %I = $1', param_col) USING folio;
    RETURN folio;
END;
$$ LANGUAGE plpgsql;