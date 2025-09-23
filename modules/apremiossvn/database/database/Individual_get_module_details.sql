-- Stored Procedure: get_module_details
-- Tipo: Catalog
-- Descripción: Obtiene el detalle de la aplicación asociada al folio según el módulo
-- Generado para formulario: Individual
-- Fecha: 2025-08-27 13:52:12

CREATE OR REPLACE FUNCTION get_module_details(modulo integer, control_otr integer)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    IF modulo = 16 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_16_contratos WHERE control_contrato = control_otr
        ) t;
    ELSIF modulo = 11 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_11_locales WHERE id_local = control_otr
        ) t;
    ELSIF modulo = 24 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM pubmain WHERE id = control_otr
        ) t;
    ELSIF modulo = 28 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ex_contrato WHERE id = control_otr
        ) t;
    ELSIF modulo = 14 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_padron WHERE id = control_otr
        ) t;
    ELSIF modulo = 13 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_13_datosrcm WHERE control_rcm = control_otr
        ) t;
    ELSE
        result := NULL;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;