-- Stored Procedure: sp_get_tramite_info
-- Tipo: Report
-- Descripción: Obtiene información básica de un trámite
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-27 17:32:45

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_id_tramite INT)
RETURNS TABLE(id_tramite INT, propietario TEXT, ubicacion TEXT, estatus TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_tramite, propietario, ubicacion, estatus FROM tramites WHERE id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;