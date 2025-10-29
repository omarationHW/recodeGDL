-- Stored Procedure: sp_get_revision_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de una revisión específica.
-- Generado para formulario: repestado
-- Fecha: 2025-08-26 17:55:36

CREATE OR REPLACE FUNCTION sp_get_revision_detalle(p_id_revision INTEGER)
RETURNS TABLE (
  id_revision INTEGER,
  feccap DATE,
  oficio VARCHAR,
  estatus VARCHAR,
  observacion TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_revision, feccap, oficio, estatus, observacion
  FROM seg_revision
  WHERE id_revision = p_id_revision;
END;
$$ LANGUAGE plpgsql;