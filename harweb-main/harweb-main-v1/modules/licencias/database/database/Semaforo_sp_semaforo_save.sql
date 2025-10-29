-- Stored Procedure: sp_semaforo_save
-- Tipo: CRUD
-- Descripción: Guarda el resultado del semáforo para un trámite y usuario
-- Generado para formulario: Semaforo
-- Fecha: 2025-08-26 18:05:28

CREATE OR REPLACE FUNCTION sp_semaforo_save(p_usuario_id INT, p_tramite_id INT, p_color VARCHAR, p_fecha TIMESTAMP)
RETURNS TABLE(id SERIAL, usuario_id INT, tramite_id INT, color VARCHAR, fecha TIMESTAMP) AS $$
BEGIN
  INSERT INTO semaforo_resultados(usuario_id, tramite_id, color, fecha)
  VALUES (p_usuario_id, p_tramite_id, p_color, p_fecha)
  RETURNING id, usuario_id, tramite_id, color, fecha;
END;
$$ LANGUAGE plpgsql;