-- Stored Procedure: sp_semaforo_get_stats
-- Tipo: Report
-- Descripción: Devuelve el conteo de rojos y verdes por usuario.
-- Generado para formulario: Semaforo
-- Fecha: 2025-08-27 19:32:03

CREATE OR REPLACE FUNCTION sp_semaforo_get_stats(p_user_id INT)
RETURNS TABLE(rojos INT, verdes INT) AS $$
BEGIN
  SELECT COUNT(*) FILTER (WHERE color = 'ROJO'), COUNT(*) FILTER (WHERE color = 'VERDE')
  INTO rojos, verdes
  FROM semaforo_tramites WHERE user_id = p_user_id;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;