-- Stored Procedure: sp_get_cuenta_trans
-- Tipo: Catalog
-- Descripción: Obtiene la cuenta de transferencia para una cuenta dada.
-- Generado para formulario: TrDocumentos
-- Fecha: 2025-08-27 01:34:50

CREATE OR REPLACE FUNCTION sp_get_cuenta_trans(
    p_moneda INTEGER,
    p_cta_mayor INTEGER,
    p_cta_sub01 INTEGER,
    p_cta_sub02 INTEGER,
    p_cta_sub03 INTEGER
) RETURNS TABLE(nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT nombre FROM ta_cuentastrans
    WHERE moneda = p_moneda
      AND cta_mayor = p_cta_mayor
      AND cta_sub01 = p_cta_sub01
      AND cta_sub02 = p_cta_sub02
      AND cta_sub03 = p_cta_sub03;
END;
$$ LANGUAGE plpgsql;