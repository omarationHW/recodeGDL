-- Stored Procedure: sp_get_cajas_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene las cajas de una oficina recaudadora.
-- Generado para formulario: ConsCapturaFecha
-- Fecha: 2025-08-26 23:13:33

CREATE OR REPLACE FUNCTION sp_get_cajas_by_oficina(p_oficina INTEGER)
RETURNS TABLE (caja VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT caja FROM ta_12_cajas WHERE id_rec = p_oficina;
END;
$$ LANGUAGE plpgsql;