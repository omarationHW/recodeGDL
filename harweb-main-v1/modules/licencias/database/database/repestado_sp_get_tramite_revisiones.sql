-- Stored Procedure: sp_get_tramite_revisiones
-- Tipo: Report
-- Descripción: Obtiene todas las revisiones asociadas a un trámite, incluyendo dependencia y observaciones.
-- Generado para formulario: repestado
-- Fecha: 2025-08-26 17:55:36

CREATE OR REPLACE FUNCTION sp_get_tramite_revisiones(p_id_tramite INTEGER)
RETURNS TABLE (
  id_revision INTEGER,
  id_tramite INTEGER,
  id_dependencia INTEGER,
  feccap DATE,
  oficio VARCHAR,
  estatus VARCHAR,
  observacion TEXT,
  dependencia VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.id_revision, r.id_tramite, r.id_dependencia, s.feccap, s.oficio, s.estatus, s.observacion, d.descripcion AS dependencia
  FROM revisiones r
  JOIN seg_revision s ON s.id_revision = r.id_revision
  JOIN c_dependencias d ON d.id_dependencia = r.id_dependencia
  WHERE r.id_tramite = p_id_tramite
  ORDER BY r.id_revision;
END;
$$ LANGUAGE plpgsql;