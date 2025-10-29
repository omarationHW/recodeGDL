-- Stored Procedure: get_cajas_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene cajas por oficina
-- Generado para formulario: ConsPagosLocales
-- Fecha: 2025-08-26 23:21:11

CREATE OR REPLACE FUNCTION get_cajas_by_oficina(p_oficina smallint) RETURNS TABLE(caja text) AS $$
BEGIN
  RETURN QUERY SELECT caja FROM ta_12_operaciones WHERE id_rec = p_oficina ORDER BY caja;
END; $$ LANGUAGE plpgsql;