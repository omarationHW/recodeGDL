-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: Acceso (EXACTO del archivo original)
-- Archivo: 01_SP_ESTACIONAMIENTOS_ACCESO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos del usuario si es correcto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_login(p_username TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, user_id INT, username TEXT, nombre TEXT, nivel INT, error TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT TRUE, id_usuario, usuario, nombre, nivel, NULL
  FROM public.usuarios
  WHERE usuario = p_username AND contrasena = crypt(p_password, contrasena) AND estado = 'A'
  LIMIT 1;
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL, 'Usuario o contraseña incorrectos';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_user_info
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_user_info(p_user_id INT)
RETURNS TABLE(id_usuario INT, usuario TEXT, nombre TEXT, nivel INT, estado TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT id_usuario, usuario, nombre, nivel, estado
  FROM public.usuarios
  WHERE id_usuario = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_folios_report
-- Tipo: Report
-- Descripción: Consulta folios por año, folio, placa o rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_folios_report(
  p_year INT,
  p_folio INT DEFAULT NULL,
  p_placa TEXT DEFAULT NULL,
  p_date_from DATE DEFAULT NULL,
  p_date_to DATE DEFAULT NULL
)
RETURNS TABLE(
  axo INT, folio INT, placa TEXT, fecha_folio DATE, estado INT, infraccion INT, tarifa NUMERIC, descripcion TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, 'Vigente'::TEXT
  FROM public.ta14_folios_adeudo a
  JOIN public.ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
  WHERE a.axo = p_year
    AND (p_folio IS NULL OR a.folio = p_folio)
    AND (p_placa IS NULL OR a.placa = p_placa)
    AND (p_date_from IS NULL OR a.fecha_folio >= p_date_from)
    AND (p_date_to IS NULL OR a.fecha_folio <= p_date_to)
  ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_register_folio
-- Tipo: CRUD
-- Descripción: Registra un nuevo folio de multa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_register_folio(
  p_year INT,
  p_folio INT,
  p_placa TEXT,
  p_fecha_folio DATE,
  p_clave INT,
  p_estado INT,
  p_agente INT,
  p_captura INT,
  p_zona INT,
  p_espacio INT
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_exists INT;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM public.ta14_folios_adeudo WHERE axo = p_year AND folio = p_folio;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT FALSE, 'Folio ya existe para el año';
    RETURN;
  END IF;
  INSERT INTO public.ta14_folios_adeudo(axo, folio, placa, fecha_folio, infraccion, estado, vigilante, num_acuerdo, fec_cap, usu_inicial, zona, espacio)
  VALUES (p_year, p_folio, p_placa, p_fecha_folio, p_clave, p_estado, p_agente, 0, NOW(), p_captura, p_zona, p_espacio);
  RETURN QUERY SELECT TRUE, 'Folio registrado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_get_catalog
-- Tipo: Catalog
-- Descripción: Obtiene catálogos varios (ejemplo: infracciones, usuarios, etc).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_catalog(p_catalog TEXT)
RETURNS SETOF RECORD AS $$
DECLARE
  sql TEXT;
BEGIN
  IF p_catalog = 'infracciones' THEN
    RETURN QUERY EXECUTE 'SELECT num_clave, descripcion FROM public.ta14_infraccion ORDER BY num_clave';
  ELSIF p_catalog = 'usuarios' THEN
    RETURN QUERY EXECUTE 'SELECT id_usuario, usuario, nombre, nivel FROM public.usuarios WHERE estado = ''A'' ORDER BY usuario';
  ELSE
    RAISE EXCEPTION 'Catálogo no soportado';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================