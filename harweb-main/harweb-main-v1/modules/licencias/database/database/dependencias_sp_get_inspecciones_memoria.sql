-- Stored Procedure: sp_get_inspecciones_memoria
-- Tipo: Report
-- Descripción: Obtiene las inspecciones actuales de un trámite (memoria/sesión)
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-26 16:01:46

CREATE OR REPLACE FUNCTION sp_get_inspecciones_memoria(p_tramite_id INT)
RETURNS TABLE(id_dependencia INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT di.id_dependencia, d.descripcion FROM dependencias_inspeccion di INNER JOIN c_dependencias d ON d.id_dependencia = di.id_dependencia WHERE di.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;