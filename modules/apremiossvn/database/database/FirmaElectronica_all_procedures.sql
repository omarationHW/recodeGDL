-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: FirmaElectronica
-- Generado: 2025-08-27 13:50:15
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_firmaelectronica_listar_folios
-- Tipo: Report
-- Descripción: Lista los folios a firmar para un módulo y fecha determinada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmaelectronica_listar_folios(pmod integer, pfec date)
RETURNS TABLE(
  cvereq integer,
  fecemi date,
  folio integer,
  diligencia integer,
  cadena1 varchar,
  cadena2 varchar,
  descripcion varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT f.cvereq, f.fecemi, f.folio, f.diligencia, f.cadena1, f.cadena2,
    CASE WHEN f.diligencia = 1 THEN 'NOTIFICACION'
         WHEN f.diligencia = 2 THEN 'REQUERIMIENTO'
         ELSE 'SECUESTRO' END AS descripcion
  FROM folios_firma f
  WHERE f.modulo = pmod AND f.fecemi = pfec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_firmaelectronica_generar_firma
-- Tipo: CRUD
-- Descripción: Genera la firma electrónica para un folio, invoca el proceso de firmado y retorna el resultado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmaelectronica_generar_firma(
  idmodulo integer,
  tipoformato integer,
  id integer,
  fecha date,
  cadenaoriginal varchar,
  ruta varchar
) RETURNS TABLE(
  codigo integer,
  descripcion varchar
) AS $$
DECLARE
  -- Simulación de proceso de firma
BEGIN
  -- Aquí se invocaría el motor de firma real
  -- Por ejemplo, si ya existe la firma, retornar código 1
  IF EXISTS (SELECT 1 FROM firmas_generadas WHERE idmodulo=idmodulo AND id=id) THEN
    RETURN QUERY SELECT 1, 'Ya existe firma para este folio';
  ELSE
    -- Insertar registro de firma (simulado)
    INSERT INTO firmas_generadas(idmodulo, tipoformato, id, fecha, cadenaoriginal, ruta, estado)
    VALUES (idmodulo, tipoformato, id, fecha, cadenaoriginal, ruta, 'GENERADA');
    RETURN QUERY SELECT 0, 'Firma generada correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_firmaelectronica_insertar_firma
-- Tipo: CRUD
-- Descripción: Inserta la firma electrónica en la tabla de apremios firmados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmaelectronica_insertar_firma(
  psec integer,
  pdigver varchar,
  pcvereg integer,
  pfalta date,
  pvig varchar,
  pfirmante varchar,
  pcargo varchar,
  pvalidez varchar,
  pffirma varchar,
  phash varchar
) RETURNS TABLE(
  graba integer,
  existe integer
) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM apremios_firmados WHERE secuencia = psec) THEN
    RETURN QUERY SELECT 0, 1;
  ELSE
    INSERT INTO apremios_firmados(secuencia, digverificador, id_modulo, fecha_graba, vigencia, firmante, cargo, validez, fecha_firmado, hash)
    VALUES (psec, pdigver, pcvereg, pfalta, pvig, pfirmante, pcargo, pvalidez, pffirma, phash);
    RETURN QUERY SELECT 1, 0;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_firmaelectronica_listar_firmas_generadas
-- Tipo: Report
-- Descripción: Lista las firmas generadas para un módulo y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmaelectronica_listar_firmas_generadas(pmod integer, pfec date)
RETURNS TABLE(
  secuencia integer,
  digverificador varchar,
  modulo integer,
  id_modulo integer,
  fechagraba timestamp,
  firmante varchar,
  cargo varchar,
  fecha_firmado varchar,
  hash varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.secuencia, a.digverificador, a.modulo, a.id_modulo, a.fechagraba, b.firmante, a.cargo, a.fecha_firmado, a.hash
  FROM tb_fea a
  JOIN tb_firmante b ON b.puesto = a.cargo
  WHERE a.modulo = pmod AND CAST(a.fechagraba AS DATE) = pfec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

