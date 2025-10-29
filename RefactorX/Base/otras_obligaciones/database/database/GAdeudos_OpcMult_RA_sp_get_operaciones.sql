-- Stored Procedure: sp_get_operaciones
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de operaciones de caja.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-28 13:01:07

CREATE OR REPLACE FUNCTION sp_get_operaciones()
RETURNS TABLE(
  id_rec smallint,
  caja text,
  operacion integer,
  id_usuario integer,
  tip_impresora text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, caja, operacion, id_usuario, tip_impresora
  FROM ta_12_operaciones
  ORDER BY id_rec, caja;
END;
$$ LANGUAGE plpgsql;