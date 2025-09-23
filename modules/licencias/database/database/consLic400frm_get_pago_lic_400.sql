-- Stored Procedure: get_pago_lic_400
-- Tipo: Catalog
-- Descripción: Obtiene los pagos asociados a una licencia 400.
-- Generado para formulario: consLic400frm
-- Fecha: 2025-08-27 17:12:15

CREATE OR REPLACE FUNCTION get_pago_lic_400(p_numlic INTEGER)
RETURNS SETOF pago_lic_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pago_lic_400 WHERE numlic = p_numlic;
END;
$$ LANGUAGE plpgsql;