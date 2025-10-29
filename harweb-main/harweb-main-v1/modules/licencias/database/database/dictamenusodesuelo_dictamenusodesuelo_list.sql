-- Stored Procedure: dictamenusodesuelo_list
-- Tipo: Catalog
-- Descripción: Obtiene el listado de dictámenes de uso de suelo (constancias)
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-27 17:38:15

CREATE OR REPLACE FUNCTION dictamenusodesuelo_list()
RETURNS TABLE(
  axo INTEGER,
  folio INTEGER,
  id_licencia INTEGER,
  solicita VARCHAR,
  partidapago VARCHAR,
  observacion VARCHAR,
  domicilio VARCHAR,
  vigente VARCHAR,
  feccap DATE,
  capturista VARCHAR,
  licencia INTEGER,
  tipo INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, licencia, tipo
    FROM constancias
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;