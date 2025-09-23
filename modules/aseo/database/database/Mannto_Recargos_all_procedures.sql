-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Recargos
-- Generado: 2025-08-27 14:47:49
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un año dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year INTEGER)
RETURNS TABLE(ano_mes TEXT, ano INTEGER, mes INTEGER, porc_recargo NUMERIC, porc_multa NUMERIC) AS $$
BEGIN
  RETURN QUERY
    SELECT TO_CHAR(aso_mes_recargo, 'YYYY-MM') AS ano_mes,
           EXTRACT(YEAR FROM aso_mes_recargo)::INTEGER AS ano,
           EXTRACT(MONTH FROM aso_mes_recargo)::INTEGER AS mes,
           porc_recargo, porc_multa
      FROM ta_16_recargos
     WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_year
     ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo si no existe para el año-mes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_create(p_year INTEGER, p_month INTEGER, p_porc_recargo NUMERIC, p_porc_multa NUMERIC)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT FALSE, 'Ya existe un recargo para ese periodo';
    RETURN;
  END IF;
  INSERT INTO ta_16_recargos (aso_mes_recargo, porc_recargo, porc_multa)
    VALUES (v_date, p_porc_recargo, p_porc_multa);
  RETURN QUERY SELECT TRUE, 'Recargo creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_update(p_year INTEGER, p_month INTEGER, p_porc_recargo NUMERIC, p_porc_multa NUMERIC)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT FALSE, 'No existe recargo para ese periodo';
    RETURN;
  END IF;
  UPDATE ta_16_recargos
     SET porc_recargo = p_porc_recargo,
         porc_multa = p_porc_multa
   WHERE aso_mes_recargo = v_date;
  RETURN QUERY SELECT TRUE, 'Recargo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo por año-mes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_delete(p_year INTEGER, p_month INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT FALSE, 'No existe recargo para ese periodo';
    RETURN;
  END IF;
  DELETE FROM ta_16_recargos WHERE aso_mes_recargo = v_date;
  RETURN QUERY SELECT TRUE, 'Recargo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

