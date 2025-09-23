-- Stored Procedure: sp_mantpagoscontratos_listar_cajas
-- Tipo: Catalog
-- Descripción: Lista las cajas disponibles para una recaudadora.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_listar_cajas(
    p_oficina_pago SMALLINT
) RETURNS TABLE (caja VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT caja FROM ta_12_cajas WHERE id_rec = p_oficina_pago ORDER BY caja;
END;
$$ LANGUAGE plpgsql;