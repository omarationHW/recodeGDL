-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consdesctosmfrm
-- Generado: 2025-08-26 23:23:39
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_list_desctos_multa
-- Tipo: Report
-- Descripción: Lista todos los descuentos otorgados para una multa municipal específica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_desctos_multa(p_id_multa INTEGER)
RETURNS TABLE (
  folio_descto INTEGER,
  datos_descto TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  por_aut INTEGER,
  monto_aut NUMERIC,
  fecha_act DATE,
  user_cap TEXT,
  us_aplico TEXT,
  fe_aplico DATE,
  vigencia TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM public.descmultampal
    WHERE id_multa = p_id_multa
    ORDER BY fecha_inicio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_descto_multa
-- Tipo: Catalog
-- Descripción: Obtiene un descuento específico por folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_descto_multa(p_folio_descto INTEGER)
RETURNS TABLE (
  folio_descto INTEGER,
  datos_descto TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  por_aut INTEGER,
  monto_aut NUMERIC,
  fecha_act DATE,
  user_cap TEXT,
  us_aplico TEXT,
  fe_aplico DATE,
  vigencia TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM public.descmultampal
    WHERE folio_descto = p_folio_descto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_create_descto_multa
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento para una multa municipal.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_descto_multa(
  p_id_multa INTEGER,
  p_tipo_descto TEXT,
  p_valor NUMERIC,
  p_autoriza INTEGER,
  p_observacion TEXT,
  p_user_cap TEXT
) RETURNS TABLE (
  folio_descto INTEGER,
  datos_descto TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  por_aut INTEGER,
  monto_aut NUMERIC,
  fecha_act DATE,
  user_cap TEXT,
  us_aplico TEXT,
  fe_aplico DATE,
  vigencia TEXT
) AS $$
DECLARE
  v_folio INTEGER;
BEGIN
  INSERT INTO public.descmultampal (id_multa, tipo_descto, valor, autoriza, observacion, user_cap, fecha_act, vigencia)
  VALUES (p_id_multa, p_tipo_descto, p_valor, p_autoriza, p_observacion, p_user_cap, NOW(), 'V')
  RETURNING folio_descto INTO v_folio;
  RETURN QUERY SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM public.descmultampal WHERE folio_descto = v_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_update_descto_multa
-- Tipo: CRUD
-- Descripción: Actualiza un descuento existente para una multa municipal.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_descto_multa(
  p_folio_descto INTEGER,
  p_tipo_descto TEXT,
  p_valor NUMERIC,
  p_autoriza INTEGER,
  p_observacion TEXT,
  p_user_cap TEXT
) RETURNS TABLE (
  folio_descto INTEGER,
  datos_descto TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  por_aut INTEGER,
  monto_aut NUMERIC,
  fecha_act DATE,
  user_cap TEXT,
  us_aplico TEXT,
  fe_aplico DATE,
  vigencia TEXT
) AS $$
BEGIN
  UPDATE public.descmultampal
  SET tipo_descto = p_tipo_descto,
      valor = p_valor,
      autoriza = p_autoriza,
      observacion = p_observacion,
      user_cap = p_user_cap,
      fecha_act = NOW()
  WHERE folio_descto = p_folio_descto;
  RETURN QUERY SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM public.descmultampal WHERE folio_descto = p_folio_descto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_delete_descto_multa
-- Tipo: CRUD
-- Descripción: Cancela (elimina lógicamente) un descuento de multa municipal.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_descto_multa(
  p_folio_descto INTEGER,
  p_user_cap TEXT
) RETURNS TABLE (
  folio_descto INTEGER,
  vigencia TEXT,
  fecha_act DATE,
  user_cap TEXT
) AS $$
BEGIN
  UPDATE public.descmultampal
  SET vigencia = 'C', fecha_act = NOW(), user_cap = p_user_cap
  WHERE folio_descto = p_folio_descto;
  RETURN QUERY SELECT folio_descto, vigencia, fecha_act, user_cap
    FROM public.descmultampal WHERE folio_descto = p_folio_descto;
END;
$$ LANGUAGE plpgsql;

-- ============================================