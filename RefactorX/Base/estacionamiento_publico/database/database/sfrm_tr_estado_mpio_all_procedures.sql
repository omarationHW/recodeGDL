-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_tr_estado_mpio
-- Generado: 2025-08-27 14:39:40
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_remesas_estado_mpio
-- Tipo: Report
-- Descripción: Devuelve las últimas 5 remesas distintas con sus fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_remesas_estado_mpio()
RETURNS TABLE(remesa TEXT, fecharemesa DATE, aplicadoteso DATE)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ON (remesa)
      remesa, fecharemesa, fecha_aplica_teso AS aplicadoteso
    FROM ta14_datos_edo
    ORDER BY remesa DESC, fecharemesa
    LIMIT 5;
END;
$$;

-- ============================================

-- SP 2/3: sp_insert_folios_estado_mpio
-- Tipo: CRUD
-- Descripción: Carga datos desde un archivo plano y los inserta en ta14_datos_edo. El archivo debe estar en formato CSV compatible.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_folios_estado_mpio(p_filepath TEXT)
RETURNS JSON
LANGUAGE plpgsql AS $$
DECLARE
  v_sql TEXT;
  v_result JSON;
BEGIN
  -- Borra temporal si existe
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tmp_datos_edo') THEN
    EXECUTE 'DROP TABLE tmp_datos_edo';
  END IF;

  -- Crea tabla temporal según estructura esperada
  EXECUTE '
    CREATE TEMP TABLE tmp_datos_edo (
      idrmunicipio INTEGER,
      tipoact TEXT,
      folio INTEGER,
      fechagenreq DATE,
      placa TEXT,
      folionot INTEGER,
      fechanot DATE,
      fechapago DATE,
      fechacancelado DATE,
      importe NUMERIC,
      clave TEXT,
      fechaalta DATE,
      fechavenc DATE,
      folioec INTEGER,
      folioecmpio INTEGER,
      gastos NUMERIC,
      remesa TEXT,
      fecharemesa DATE
    )';

  -- Carga archivo CSV a tabla temporal
  v_sql := format('COPY tmp_datos_edo FROM %L WITH (FORMAT csv, HEADER false, DELIMITER '','')', p_filepath);
  EXECUTE v_sql;

  -- Inserta en tabla destino
  INSERT INTO ta14_datos_edo (
    idrmunicipio, tipoact, folio, fechagenreq, placa, folionot, fechanot, fechapago, fechacancelado, importe,
    clave, fechaalta, fechavenc, folioec, folioecmpio, gastos, remesa, fecharemesa
  )
  SELECT * FROM tmp_datos_edo;

  v_result := json_build_object('inserted', (SELECT COUNT(*) FROM tmp_datos_edo));
  RETURN v_result;
END;
$$;

-- ============================================

-- SP 3/3: spd_delesta01
-- Tipo: CRUD
-- Descripción: Procesa una operación específica sobre ta14_datos_edo (ejemplo: eliminar, actualizar, etc).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_delesta01(
  axo SMALLINT,
  folio INTEGER,
  placa TEXT,
  convenio INTEGER,
  fecha DATE,
  reca SMALLINT,
  caja TEXT,
  oper INTEGER,
  usuauto INTEGER,
  opc SMALLINT
)
RETURNS TABLE(result_code SMALLINT, result_msg TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  -- Ejemplo: Eliminar registro por folio y placa
  IF opc = 1 THEN
    DELETE FROM ta14_datos_edo WHERE folio = folio AND placa = placa;
    RETURN QUERY SELECT 0, 'Registro eliminado';
  ELSE
    RETURN QUERY SELECT 1, 'Operación no implementada';
  END IF;
END;
$$;

-- ============================================

