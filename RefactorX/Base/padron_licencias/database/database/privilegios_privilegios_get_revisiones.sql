-- Stored Procedure: privilegios_get_revisiones
-- Tipo: Report
-- Descripción: Obtiene revisiones realizadas por usuario y rango de fechas
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_revisiones(p_usuario TEXT, p_fechaini DATE, p_fechafin DATE)
RETURNS TABLE(
  id_revision INTEGER, id_tramite INTEGER, dependencia TEXT, fecha_inicio DATE, fecha_termino DATE, estatus_revision TEXT, fecha_revision DATE, usr_revisa TEXT, estatus_seguimiento TEXT, observacion TEXT, fecha_seguimiento DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.id_revision, r.id_tramite, d.descripcion as dependencia, r.fecha_inicio, r.fecha_termino, r.estatus as estatus_revision,
    s.fecha_revision, s.usr_revisa, s.estatus as estatus_seguimiento, s.observacion, s.feccap as fecha_seguimiento
  FROM revisiones r
  LEFT JOIN seg_revision s ON s.id_revision = r.id_revision
  LEFT JOIN c_dependencias d ON d.id_dependencia = r.id_dependencia
  WHERE s.feccap BETWEEN p_fechaini AND p_fechafin
    AND s.usr_revisa = p_usuario
  ORDER BY s.feccap;
END;
$$ LANGUAGE plpgsql;