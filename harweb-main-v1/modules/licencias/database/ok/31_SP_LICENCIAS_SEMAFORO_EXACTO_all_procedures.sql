-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SEMAFORO (EXACTO del archivo original)
-- Archivo: 31_SP_LICENCIAS_SEMAFORO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SEMAFORO (EXACTO del archivo original)
-- Archivo: 31_SP_LICENCIAS_SEMAFORO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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

