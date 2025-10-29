-- Stored Procedure: sp_get_cajas_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene las cajas disponibles para una oficina.
-- Generado para formulario: CargaPagEspecial
-- Fecha: 2025-08-26 19:53:42

CREATE OR REPLACE FUNCTION sp_get_cajas_by_oficina(p_oficina SMALLINT)
RETURNS TABLE (
  caja VARCHAR
) AS $$
BEGIN
  RETURN QUERY
    SELECT caja FROM ta_12_operaciones WHERE id_rec = p_oficina ORDER BY caja ASC;
END;
$$ LANGUAGE plpgsql;