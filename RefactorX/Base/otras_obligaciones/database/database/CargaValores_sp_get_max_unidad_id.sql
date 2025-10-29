-- Stored Procedure: sp_get_max_unidad_id
-- Tipo: Catalog
-- Descripción: Obtiene el máximo id_34_unidad actual.
-- Generado para formulario: CargaValores
-- Fecha: 2025-08-27 23:13:46

CREATE OR REPLACE FUNCTION sp_get_max_unidad_id()
RETURNS integer AS $$
DECLARE
  maxid integer;
BEGIN
  SELECT COALESCE(MAX(id_34_unidad),0) INTO maxid FROM t34_unidades;
  RETURN maxid;
END;
$$ LANGUAGE plpgsql;