-- Stored Procedure: sp_remove_dependencia_inspeccion
-- Tipo: CRUD
-- Descripción: Elimina una dependencia de las inspecciones de un trámite
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-26 16:01:46

CREATE OR REPLACE FUNCTION sp_remove_dependencia_inspeccion(p_tramite_id INT, p_id_dependencia INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM dependencias_inspeccion WHERE id_tramite = p_tramite_id AND id_dependencia = p_id_dependencia;
END;
$$ LANGUAGE plpgsql;