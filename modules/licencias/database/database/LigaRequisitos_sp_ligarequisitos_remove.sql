-- Stored Procedure: sp_ligarequisitos_remove
-- Tipo: CRUD
-- Descripción: Elimina un requisito de un giro.
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-26 17:13:30

CREATE OR REPLACE FUNCTION sp_ligarequisitos_remove(p_id_giro INT, p_req INT)
RETURNS TEXT AS $$
DECLARE
  deleted INT;
BEGIN
  DELETE FROM giro_req WHERE id_giro = p_id_giro AND req = p_req RETURNING 1 INTO deleted;
  IF deleted IS NULL THEN
    RETURN 'No se encontró el requisito para eliminar';
  END IF;
  RETURN 'Requisito eliminado correctamente';
END;
$$ LANGUAGE plpgsql;