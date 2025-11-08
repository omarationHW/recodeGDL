-- Stored Procedure: sp_get_tramite_info
-- Tipo: Report
-- Descripción: Obtiene información básica de un trámite
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-27 16:41:18

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_tramite_id integer)
RETURNS TABLE(id_tramite integer, cvecuenta integer, recaud integer) AS $$
BEGIN
  RETURN QUERY SELECT id_tramite, cvecuenta, recaud FROM tramites WHERE id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;