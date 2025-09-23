-- Stored Procedure: sp_listxFec_get_vigencias
-- Tipo: Catalog
-- Descripción: Obtiene las vigencias disponibles (claves tipo 5)
-- Generado para formulario: ListxFec
-- Fecha: 2025-08-27 20:48:46

CREATE OR REPLACE FUNCTION sp_listxFec_get_vigencias()
RETURNS TABLE(clave VARCHAR, descrip VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT clave, descrip FROM ta_15_claves WHERE tipo_clave=5 ORDER BY clave;
END;
$$ LANGUAGE plpgsql;