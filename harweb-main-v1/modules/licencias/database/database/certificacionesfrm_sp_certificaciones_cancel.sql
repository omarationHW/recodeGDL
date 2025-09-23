-- Stored Procedure: sp_certificaciones_cancel
-- Tipo: CRUD
-- Descripción: Cancela una certificación (marca como no vigente y guarda motivo)
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-27 17:08:49

CREATE OR REPLACE FUNCTION sp_certificaciones_cancel(p_id INT, p_motivo TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET vigente = 'C', observacion = p_motivo, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;