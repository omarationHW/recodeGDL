-- Stored Procedure: sp_get_observaciones_multa
-- Tipo: CRUD
-- Descripción: Obtiene las observaciones y comentario de una multa por su ID
-- Generado para formulario: consobsmulfrm
-- Fecha: 2025-08-26 23:35:31

CREATE OR REPLACE FUNCTION sp_get_observaciones_multa(p_id_multa INTEGER)
RETURNS TABLE(id_multa INTEGER, observacion TEXT, comentario TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_multa, observacion, comentario FROM multas WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;