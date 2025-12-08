-- FIX APREMIOSSVN SPs - 2025-12-05
-- Corrige los SPs para usar la tabla correcta ta_15_aprem400

-- 1. SP para listar expedientes
CREATE OR REPLACE FUNCTION apremiossvn_expedientes_list()
RETURNS TABLE(
  control INTEGER,
  expediente VARCHAR(50),
  folio INTEGER,
  datos VARCHAR(100),
  vigencia VARCHAR(10),
  fecha_emision DATE,
  zona_rec SMALLINT,
  importe NUMERIC(16,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.control,
    CONCAT('EXP-', a.zona_rec::TEXT, '-', a.folreq::TEXT)::VARCHAR(50) AS expediente,
    a.folreq AS folio,
    CONCAT('Zona ', a.zona_rec::TEXT, ' - Clave ', a.cvelet)::VARCHAR(100) AS datos,
    CASE
      WHEN a.vigreq = '1' THEN 'VIGENTE'
      WHEN a.vigreq = 'B' THEN 'BAJA'
      ELSE 'PENDIENTE'
    END::VARCHAR(10) AS vigencia,
    a.fecreq AS fecha_emision,
    a.zona_rec,
    a.impcuo AS importe
  FROM ta_15_aprem400 a
  ORDER BY a.fecreq DESC NULLS LAST, a.control DESC
  LIMIT 500;
END;
$$ LANGUAGE plpgsql;

-- 2. SP para listar fases
CREATE OR REPLACE FUNCTION sp_fases_list()
RETURNS TABLE(
  control INTEGER,
  expediente VARCHAR(50),
  folio VARCHAR(50),
  fase_actual VARCHAR(50),
  fecha_fase DATE,
  zona_rec SMALLINT,
  vigencia VARCHAR(10),
  importe NUMERIC(16,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.control,
    CONCAT('EXP-', a.zona_rec::TEXT, '-', a.folreq::TEXT)::VARCHAR(50) AS expediente,
    a.folreq::VARCHAR(50) AS folio,
    CASE
      WHEN a.vigreq = '1' THEN 'VIGENTE'
      WHEN a.vigreq = 'B' THEN 'BAJA'
      ELSE 'PENDIENTE'
    END::VARCHAR(50) AS fase_actual,
    a.fecreq AS fecha_fase,
    a.zona_rec,
    a.vigreq::VARCHAR(10) AS vigencia,
    a.impcuo AS importe
  FROM ta_15_aprem400 a
  ORDER BY a.fecreq DESC NULLS LAST, a.control DESC
  LIMIT 500;
END;
$$ LANGUAGE plpgsql;

-- 3. SP para listar actuaciones
CREATE OR REPLACE FUNCTION sp_actuaciones_list(
  p_expediente VARCHAR DEFAULT '',
  p_desde VARCHAR DEFAULT '',
  p_hasta VARCHAR DEFAULT ''
)
RETURNS TABLE(
  control INTEGER,
  expediente VARCHAR(50),
  folio INTEGER,
  zona_rec SMALLINT,
  fecha_req DATE,
  fecha_pra DATE,
  vigencia VARCHAR(10),
  ejecutor INTEGER,
  importe NUMERIC(16,2),
  observaciones VARCHAR(30)
) AS $$
DECLARE
  v_desde DATE;
  v_hasta DATE;
BEGIN
  -- Convertir strings a fechas si no estan vacios
  v_desde := NULLIF(p_desde, '')::DATE;
  v_hasta := NULLIF(p_hasta, '')::DATE;

  RETURN QUERY
  SELECT
    a.control,
    CONCAT('EXP-', a.zona_rec::TEXT, '-', a.folreq::TEXT)::VARCHAR(50) AS expediente,
    a.folreq AS folio,
    a.zona_rec,
    a.fecreq AS fecha_req,
    a.fecpra AS fecha_pra,
    a.vigreq::VARCHAR(10) AS vigencia,
    a.ejereq AS ejecutor,
    a.impcuo AS importe,
    a.observr AS observaciones
  FROM ta_15_aprem400 a
  WHERE (p_expediente = '' OR CONCAT('EXP-', a.zona_rec::TEXT, '-', a.folreq::TEXT) ILIKE '%' || p_expediente || '%')
    AND (v_desde IS NULL OR a.fecreq >= v_desde)
    AND (v_hasta IS NULL OR a.fecreq <= v_hasta)
  ORDER BY a.fecreq DESC NULLS LAST, a.control DESC
  LIMIT 500;
END;
$$ LANGUAGE plpgsql;

-- 4. SP para cambiar fase
CREATE OR REPLACE FUNCTION sp_cambiar_fase(
  p_expediente VARCHAR,
  p_fase VARCHAR
)
RETURNS VARCHAR AS $$
DECLARE
  v_control INTEGER;
  v_zona SMALLINT;
  v_folio INTEGER;
BEGIN
  -- Extraer zona y folio del expediente (formato: EXP-zona-folio)
  v_zona := SPLIT_PART(p_expediente, '-', 2)::SMALLINT;
  v_folio := SPLIT_PART(p_expediente, '-', 3)::INTEGER;

  -- Buscar el registro
  SELECT control INTO v_control
  FROM ta_15_aprem400
  WHERE zona_rec = v_zona AND folreq = v_folio
  LIMIT 1;

  IF v_control IS NULL THEN
    RETURN 'ERROR: Expediente no encontrado';
  END IF;

  -- Actualizar vigencia segun fase
  UPDATE ta_15_aprem400
  SET vigreq = CASE
    WHEN p_fase = 'BAJA' THEN 'B'
    ELSE '1'
  END,
  actreq = CURRENT_DATE
  WHERE control = v_control;

  RETURN 'OK: Fase actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

-- 5. SP estadisticas expedientes
CREATE OR REPLACE FUNCTION apremiossvn_expedientes_estadisticas()
RETURNS TABLE(
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total BIGINT,
  porcentaje NUMERIC(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total BIGINT;
BEGIN
  SELECT COUNT(*) INTO v_total FROM ta_15_aprem400;

  RETURN QUERY
  SELECT
    'TOTAL'::VARCHAR(50) AS categoria,
    'Total Expedientes'::VARCHAR(100) AS descripcion,
    v_total AS total,
    100.00::NUMERIC(5,2) AS porcentaje,
    'primary'::VARCHAR(20) AS clase;

  RETURN QUERY
  SELECT
    'VIGENTES'::VARCHAR(50) AS categoria,
    'Expedientes Vigentes'::VARCHAR(100) AS descripcion,
    COUNT(*)::BIGINT AS total,
    (COUNT(*) * 100.0 / NULLIF(v_total, 0))::NUMERIC(5,2) AS porcentaje,
    'success'::VARCHAR(20) AS clase
  FROM ta_15_aprem400 WHERE vigreq = '1';

  RETURN QUERY
  SELECT
    'BAJAS'::VARCHAR(50) AS categoria,
    'Expedientes en Baja'::VARCHAR(100) AS descripcion,
    COUNT(*)::BIGINT AS total,
    (COUNT(*) * 100.0 / NULLIF(v_total, 0))::NUMERIC(5,2) AS porcentaje,
    'danger'::VARCHAR(20) AS clase
  FROM ta_15_aprem400 WHERE vigreq = 'B';
END;
$$ LANGUAGE plpgsql;
