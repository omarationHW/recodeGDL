-- Stored Procedure: sp_get_revisiones
-- Tipo: Report
-- Descripción: Obtiene las revisiones realizadas por un usuario en un rango de fechas.
-- Generado para formulario: privilegios
-- Fecha: 2025-08-27 18:54:11

CREATE OR REPLACE FUNCTION sp_get_revisiones(
    p_fechaini DATE,
    p_fechafin DATE,
    p_usuario VARCHAR
)
RETURNS TABLE (
    id_revision INTEGER,
    id_tramite INTEGER,
    dependencia VARCHAR,
    fecha_inicio DATE,
    fecha_termino DATE,
    estatus_revision VARCHAR,
    fecha_revision DATE,
    usr_revisa VARCHAR,
    estatus_seguimiento VARCHAR,
    observacion TEXT,
    fecha_seguimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_revision, r.id_tramite, d.descripcion AS dependencia, r.fecha_inicio, r.fecha_termino, r.estatus AS estatus_revision,
           s.fecha_revision, s.usr_revisa, s.estatus AS estatus_seguimiento, s.observacion, s.feccap AS fecha_seguimiento
    FROM revisiones r
    LEFT JOIN seg_revision s ON s.id_revision = r.id_revision
    LEFT JOIN c_dependencias d ON d.id_dependencia = r.id_dependencia
    WHERE s.feccap BETWEEN p_fechaini AND p_fechafin
      AND s.usr_revisa = p_usuario
    ORDER BY s.feccap;
END;
$$ LANGUAGE plpgsql;