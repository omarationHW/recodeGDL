-- Stored Procedure: sp_add_dependencia_inspeccion
-- Tipo: CRUD
-- Descripción: Agrega una dependencia a las inspecciones de un trámite
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-26 16:01:46

CREATE OR REPLACE FUNCTION sp_add_dependencia_inspeccion(p_tramite_id INT, p_id_dependencia INT, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM dependencias_inspeccion WHERE id_tramite = p_tramite_id AND id_dependencia = p_id_dependencia) THEN
    RAISE EXCEPTION 'Ya existe la inspección para esta dependencia';
  END IF;
  INSERT INTO dependencias_inspeccion (id_tramite, id_dependencia, usuario_alta, fecha_alta)
  VALUES (p_tramite_id, p_id_dependencia, p_usuario, NOW());
END;
$$ LANGUAGE plpgsql;