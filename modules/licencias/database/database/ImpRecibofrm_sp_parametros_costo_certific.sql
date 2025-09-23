-- Stored Procedure: sp_parametros_costo_certific
-- Tipo: Catalog
-- Descripción: Obtiene el costo de certificación desde la tabla de parámetros.
-- Generado para formulario: ImpRecibofrm
-- Fecha: 2025-08-26 17:05:07

CREATE OR REPLACE FUNCTION sp_parametros_costo_certific()
RETURNS NUMERIC AS $$
DECLARE
    v_costo NUMERIC;
BEGIN
    SELECT costo_certific INTO v_costo FROM parametros_lic LIMIT 1;
    RETURN v_costo;
END;
$$ LANGUAGE plpgsql;