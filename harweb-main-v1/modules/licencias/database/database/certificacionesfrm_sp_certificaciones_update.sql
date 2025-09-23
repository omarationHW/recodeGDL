-- Stored Procedure: sp_certificaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza una certificación existente
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-27 17:08:49

CREATE OR REPLACE FUNCTION sp_certificaciones_update(p_id INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET observacion = p_observacion, partidapago = p_partidapago, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;