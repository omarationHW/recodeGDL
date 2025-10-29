-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABCEjec
-- Generado: 2025-08-27 13:29:40
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_ejecutores_list
-- Tipo: Catalog
-- Descripción: Lista todos los ejecutores de una recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_list(p_id_rec integer)
RETURNS TABLE (
  cve_eje integer,
  ini_rfc varchar(4),
  fec_rfc date,
  hom_rfc varchar(3),
  nombre varchar(60),
  id_rec smallint,
  oficio varchar(14),
  fecinic date,
  fecterm date,
  vigencia char(1)
) AS $$
BEGIN
  RETURN QUERY
    SELECT cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, oficio, fecinic, fecterm, vigencia
    FROM ta_15_ejecutores
    WHERE id_rec = p_id_rec
    ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_ejecutores_get
-- Tipo: Catalog
-- Descripción: Obtiene un ejecutor específico por clave y recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_get(p_cve_eje integer, p_id_rec integer)
RETURNS TABLE (
  cve_eje integer,
  ini_rfc varchar(4),
  fec_rfc date,
  hom_rfc varchar(3),
  nombre varchar(60),
  id_rec smallint,
  oficio varchar(14),
  fecinic date,
  fecterm date,
  vigencia char(1)
) AS $$
BEGIN
  RETURN QUERY
    SELECT cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, oficio, fecinic, fecterm, vigencia
    FROM ta_15_ejecutores
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_ejecutores_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo ejecutor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_create(
  p_cve_eje integer,
  p_ini_rfc varchar(4),
  p_fec_rfc date,
  p_hom_rfc varchar(3),
  p_nombre varchar(60),
  p_id_rec smallint,
  p_oficio varchar(14),
  p_fecinic date,
  p_fecterm date
) RETURNS TABLE (result text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_15_ejecutores WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
  IF existe > 0 THEN
    RETURN QUERY SELECT 'Ya existe ejecutor con ese número en la recaudadora';
    RETURN;
  END IF;
  INSERT INTO ta_15_ejecutores (
    cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, oficio, fecinic, fecterm, vigencia
  ) VALUES (
    p_cve_eje, p_ini_rfc, p_fec_rfc, p_hom_rfc, p_nombre, p_id_rec, p_oficio, p_fecinic, p_fecterm, 'A'
  );
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_ejecutores_update
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un ejecutor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_update(
  p_cve_eje integer,
  p_id_rec smallint,
  p_ini_rfc varchar(4),
  p_fec_rfc date,
  p_hom_rfc varchar(3),
  p_nombre varchar(60),
  p_oficio varchar(14),
  p_fecinic date,
  p_fecterm date
) RETURNS TABLE (result text) AS $$
BEGIN
  UPDATE ta_15_ejecutores
  SET ini_rfc = p_ini_rfc,
      fec_rfc = p_fec_rfc,
      hom_rfc = p_hom_rfc,
      nombre = p_nombre,
      oficio = p_oficio,
      fecinic = p_fecinic,
      fecterm = p_fecterm,
      vigencia = 'A'
  WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
  IF FOUND THEN
    RETURN QUERY SELECT 'OK';
  ELSE
    RETURN QUERY SELECT 'No existe ejecutor';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_ejecutores_toggle_vigencia
-- Tipo: CRUD
-- Descripción: Cambia la vigencia de un ejecutor (baja/reactiva)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_toggle_vigencia(p_cve_eje integer, p_id_rec smallint)
RETURNS TABLE (result text) AS $$
DECLARE
  v_actual char(1);
BEGIN
  SELECT vigencia INTO v_actual FROM ta_15_ejecutores WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
  IF v_actual IS NULL THEN
    RETURN QUERY SELECT 'No existe ejecutor';
    RETURN;
  END IF;
  IF v_actual = 'A' THEN
    UPDATE ta_15_ejecutores SET vigencia = 'B' WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    RETURN QUERY SELECT 'Baja';
  ELSE
    UPDATE ta_15_ejecutores SET vigencia = 'A' WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    RETURN QUERY SELECT 'Reactivado';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_ejecutores_historia_insert
-- Tipo: CRUD
-- Descripción: Registra un cambio en el historial de ejecutores (opcional, para auditoría)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ejecutores_historia_insert(
  p_cve_eje integer,
  p_id_rec smallint,
  p_usuario integer,
  p_accion varchar(20),
  p_fecha timestamp
) RETURNS void AS $$
BEGIN
  INSERT INTO ta_15_ejecutores_historia (cve_eje, id_rec, usuario, accion, fecha)
  VALUES (p_cve_eje, p_id_rec, p_usuario, p_accion, p_fecha);
END;
$$ LANGUAGE plpgsql;

-- ============================================

