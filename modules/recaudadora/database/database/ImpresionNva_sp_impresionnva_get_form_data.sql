-- Stored Procedure: sp_impresionnva_get_form_data
-- Tipo: CRUD
-- Descripción: Devuelve los datos necesarios para inicializar el formulario ImpresionNva (en este caso, vacío).
-- Generado para formulario: ImpresionNva
-- Fecha: 2025-08-27 12:25:26

CREATE OR REPLACE FUNCTION sp_impresionnva_get_form_data()
RETURNS JSON AS $$
BEGIN
    RETURN '{}'::json;
END;
$$ LANGUAGE plpgsql;