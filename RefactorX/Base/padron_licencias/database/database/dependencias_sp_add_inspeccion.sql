-- Stored Procedure: sp_add_inspeccion
-- Tipo: CRUD
-- Descripción: Agrega una inspección/revisión a un trámite
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-27 17:32:45

CREATE OR REPLACE FUNCTION sp_add_inspeccion(p_id_tramite INT, p_id_dependencia INT, p_usuario TEXT)
RETURNS TEXT AS $$
DECLARE
  v_exists INT;
  v_id_revision INT;
  v_desc TEXT;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM revisiones WHERE id_tramite = p_id_tramite AND id_dependencia = p_id_dependencia AND estatus = 'V';
  IF v_exists > 0 THEN
    RETURN 'Ya existe esta inspección para el trámite';
  END IF;
  SELECT descripcion INTO v_desc FROM c_dependencias WHERE id_dependencia = p_id_dependencia;
  INSERT INTO revisiones (id_tramite, id_dependencia, fecha_inicio, estatus, descripcion)
    VALUES (p_id_tramite, p_id_dependencia, NOW(), 'V', v_desc)
    RETURNING id_revision INTO v_id_revision;
  INSERT INTO seg_revision (id_revision, estatus, feccap, usr_revisa)
    VALUES (v_id_revision, 'V', NOW(), p_usuario);
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;