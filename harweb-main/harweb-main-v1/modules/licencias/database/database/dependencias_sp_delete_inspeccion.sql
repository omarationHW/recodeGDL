-- Stored Procedure: sp_delete_inspeccion
-- Tipo: CRUD
-- Descripción: Elimina una inspección/revisión de un trámite
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-27 17:32:45

CREATE OR REPLACE FUNCTION sp_delete_inspeccion(p_id_tramite INT, p_id_dependencia INT)
RETURNS TEXT AS $$
DECLARE
  v_id_revision INT;
BEGIN
  SELECT id_revision INTO v_id_revision FROM revisiones WHERE id_tramite = p_id_tramite AND id_dependencia = p_id_dependencia AND estatus = 'V' LIMIT 1;
  IF v_id_revision IS NULL THEN
    RETURN 'No existe la inspección para eliminar';
  END IF;
  DELETE FROM seg_revision WHERE id_revision = v_id_revision;
  DELETE FROM revisiones WHERE id_revision = v_id_revision;
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;