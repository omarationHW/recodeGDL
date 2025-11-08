-- Stored Procedure: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los mercados de una recaudadora con tipo_emision = 'D' (diskette/caja).
-- Generado para formulario: EmisionLibertad
-- Fecha: 2025-08-26 23:51:55

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(p_oficina INT)
RETURNS TABLE(num_mercado_nvo INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_oficina AND tipo_emision = 'D' ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;