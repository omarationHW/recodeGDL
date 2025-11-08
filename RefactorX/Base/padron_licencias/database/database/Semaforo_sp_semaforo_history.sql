-- Stored Procedure: sp_semaforo_history
-- Tipo: Report
-- Descripción: Obtiene el historial de resultados del semáforo por usuario o trámite
-- Generado para formulario: Semaforo
-- Fecha: 2025-08-26 18:05:28

CREATE OR REPLACE FUNCTION sp_semaforo_history(p_usuario_id INT DEFAULT NULL, p_tramite_id INT DEFAULT NULL)
RETURNS TABLE(id INT, usuario_id INT, tramite_id INT, color VARCHAR, fecha TIMESTAMP) AS $$
BEGIN
  RETURN QUERY
    SELECT id, usuario_id, tramite_id, color, fecha
    FROM semaforo_resultados
    WHERE (p_usuario_id IS NULL OR usuario_id = p_usuario_id)
      AND (p_tramite_id IS NULL OR tramite_id = p_tramite_id)
    ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;