-- Stored Procedure: sp_get_tramite_inspecciones
-- Tipo: Report
-- Descripción: Obtiene las inspecciones/revisiones actuales de un trámite
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-27 17:32:45

CREATE OR REPLACE FUNCTION sp_get_tramite_inspecciones(p_id_tramite INT)
RETURNS TABLE(id_revision INT, id_dependencia INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT r.id_revision, r.id_dependencia, d.descripcion
    FROM revisiones r
    INNER JOIN c_dependencias d ON r.id_dependencia = d.id_dependencia
    WHERE r.id_tramite = p_id_tramite AND r.estatus = 'V'
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;