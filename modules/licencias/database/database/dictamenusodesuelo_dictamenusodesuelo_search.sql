-- Stored Procedure: dictamenusodesuelo_search
-- Tipo: Catalog
-- Descripción: Búsqueda avanzada de dictámenes por año, folio, licencia o rango de fechas
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-27 17:38:15

CREATE OR REPLACE FUNCTION dictamenusodesuelo_search(
  p_axo INTEGER DEFAULT NULL,
  p_folio INTEGER DEFAULT NULL,
  p_licencia INTEGER DEFAULT NULL,
  p_fecha_ini DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT NULL
)
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
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_licencia IS NULL OR id_licencia = p_licencia)
      AND (p_fecha_ini IS NULL OR feccap >= p_fecha_ini)
      AND (p_fecha_fin IS NULL OR feccap <= p_fecha_fin)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;