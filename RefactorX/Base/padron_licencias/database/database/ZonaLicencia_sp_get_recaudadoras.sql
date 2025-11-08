-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene las recaudadoras activas
-- Generado para formulario: ZonaLicencia
-- Fecha: 2025-08-27 19:54:46

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(recaud SMALLINT, descripcion VARCHAR, mpio SMALLINT, recaudador VARCHAR, domicilio VARCHAR, feccap DATE, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT recaud, descripcion, mpio, recaudador, domicilio, feccap, capturista
  FROM c_recaud
  WHERE recaud <= 5;
END;
$$ LANGUAGE plpgsql;