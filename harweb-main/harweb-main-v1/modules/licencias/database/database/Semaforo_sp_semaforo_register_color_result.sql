-- Stored Procedure: sp_semaforo_register_color_result
-- Tipo: CRUD
-- Descripción: Registra el resultado del semáforo para un trámite/licencia.
-- Generado para formulario: Semaforo
-- Fecha: 2025-08-27 19:32:03

CREATE OR REPLACE FUNCTION sp_semaforo_register_color_result(
  p_tramite_id INT,
  p_color VARCHAR,
  p_user_id INT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO semaforo_tramites(tramite_id, color, user_id, created_at)
  VALUES (p_tramite_id, p_color, p_user_id, NOW());
END;
$$ LANGUAGE plpgsql;