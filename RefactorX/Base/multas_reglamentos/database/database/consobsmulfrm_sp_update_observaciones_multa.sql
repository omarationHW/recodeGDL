-- Stored Procedure: sp_update_observaciones_multa
-- Tipo: CRUD
-- Descripción: Actualiza las observaciones y comentario de una multa
-- Generado para formulario: consobsmulfrm
-- Fecha: 2025-08-26 23:35:31

CREATE OR REPLACE FUNCTION sp_update_observaciones_multa(p_id_multa INTEGER, p_observacion TEXT, p_comentario TEXT)
RETURNS INTEGER AS $$
BEGIN
  UPDATE multas SET observacion = p_observacion, comentario = p_comentario WHERE id_multa = p_id_multa;
  RETURN 1;
END;
$$ LANGUAGE plpgsql;