-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Semaforo
-- Generado: 2025-08-27 19:32:03
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_semaforo_get_random_color
-- Tipo: CRUD
-- Descripción: Devuelve un color aleatorio (ROJO o VERDE) y el número generado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_semaforo_get_random_color()
RETURNS TABLE(color VARCHAR, numcolor INT) AS $$
DECLARE
  n INT;
BEGIN
  n := floor(random()*100 + 1);
  IF n <= 10 THEN
    color := 'ROJO';
  ELSE
    color := 'VERDE';
  END IF;
  numcolor := n;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_semaforo_register_color_result
-- Tipo: CRUD
-- Descripción: Registra el resultado del semáforo para un trámite/licencia.
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: sp_semaforo_get_stats
-- Tipo: Report
-- Descripción: Devuelve el conteo de rojos y verdes por usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_semaforo_get_stats(p_user_id INT)
RETURNS TABLE(rojos INT, verdes INT) AS $$
BEGIN
  SELECT COUNT(*) FILTER (WHERE color = 'ROJO'), COUNT(*) FILTER (WHERE color = 'VERDE')
  INTO rojos, verdes
  FROM semaforo_tramites WHERE user_id = p_user_id;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

