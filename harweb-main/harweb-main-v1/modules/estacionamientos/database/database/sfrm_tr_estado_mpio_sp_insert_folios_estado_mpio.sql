-- Stored Procedure: sp_insert_folios_estado_mpio
-- Tipo: CRUD
-- Descripción: Carga datos desde un archivo plano y los inserta en ta14_datos_edo. El archivo debe estar en formato CSV compatible.
-- Generado para formulario: sfrm_tr_estado_mpio
-- Fecha: 2025-08-27 14:39:40

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