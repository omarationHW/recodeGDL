-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Firma Electrónica
-- Archivo: 14_SP_APREMIOSSVN_FIRMA_ELECTRONICA_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 4
-- ============================================

-- SP 1/4: SP_APREMIOSSVN_FIRMAELECTRONICA_LISTAR_FOLIOS
-- Tipo: Report
-- Descripción: Lista los folios a firmar para un módulo y fecha determinada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMAELECTRONICA_LISTAR_FOLIOS(pmod integer, pfec date)
RETURNS TABLE(
  cvereq integer,
  fecemi date,
  folio integer,
  diligencia integer,
  cadena1 varchar,
  cadena2 varchar,
  descripcion varchar,
  ejecutor_nombre varchar,
  importe_total numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.cvereq, 
    f.fecemi, 
    f.folio, 
    f.diligencia, 
    f.cadena1, 
    f.cadena2,
    CASE WHEN f.diligencia = 1 THEN 'NOTIFICACION'
         WHEN f.diligencia = 2 THEN 'REQUERIMIENTO'
         ELSE 'SECUESTRO' END AS descripcion,
    COALESCE(e.nombre, 'Sin asignar') AS ejecutor_nombre,
    COALESCE(a.importe_global, 0) AS importe_total
  FROM public.folios_firma f
  LEFT JOIN public.ta_15_apremios a ON f.folio = a.folio AND a.modulo = pmod
  LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
  WHERE f.modulo = pmod AND f.fecemi = pfec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: SP_APREMIOSSVN_FIRMAELECTRONICA_GENERAR_FIRMA
-- Tipo: CRUD
-- Descripción: Genera la firma electrónica para un folio, invoca el proceso de firmado y retorna el resultado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMAELECTRONICA_GENERAR_FIRMA(
  idmodulo integer,
  tipoformato integer,
  id integer,
  fecha date,
  cadenaoriginal varchar,
  ruta varchar
) RETURNS TABLE(
  codigo integer,
  descripcion varchar,
  hash_generado varchar
) AS $$
DECLARE
  v_hash varchar;
BEGIN
  -- Generar hash de la cadena original
  v_hash := md5(cadenaoriginal || fecha::text || idmodulo::text || id::text);
  
  -- Verificar si ya existe la firma
  IF EXISTS (SELECT 1 FROM public.firmas_generadas WHERE idmodulo = idmodulo AND id = id AND fecha = fecha) THEN
    RETURN QUERY SELECT 1, 'Ya existe firma para este folio', v_hash;
  ELSE
    -- Insertar registro de firma
    INSERT INTO public.firmas_generadas(idmodulo, tipoformato, id, fecha, cadenaoriginal, ruta, estado, hash, fecha_creacion)
    VALUES (idmodulo, tipoformato, id, fecha, cadenaoriginal, ruta, 'GENERADA', v_hash, NOW());
    
    -- Actualizar el estatus del apremio
    UPDATE public.ta_15_apremios 
    SET clave_practicado = 'F', fecha_actualiz = NOW()
    WHERE folio = id AND modulo = idmodulo;
    
    RETURN QUERY SELECT 0, 'Firma generada correctamente', v_hash;
  END IF;
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT -1, 'Error al generar firma: ' || SQLERRM, '';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: SP_APREMIOSSVN_FIRMAELECTRONICA_INSERTAR_FIRMA
-- Tipo: CRUD
-- Descripción: Inserta la firma electrónica en la tabla de apremios firmados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMAELECTRONICA_INSERTAR_FIRMA(
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
  existe integer,
  mensaje varchar
) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.apremios_firmados WHERE secuencia = psec) THEN
    RETURN QUERY SELECT 0, 1, 'Ya existe firma para esta secuencia';
  ELSE
    INSERT INTO public.apremios_firmados(
      secuencia, 
      digverificador, 
      id_modulo, 
      fecha_graba, 
      vigencia, 
      firmante, 
      cargo, 
      validez, 
      fecha_firmado, 
      hash,
      fecha_creacion
    )
    VALUES (
      psec, 
      pdigver, 
      pcvereg, 
      pfalta, 
      pvig, 
      pfirmante, 
      pcargo, 
      pvalidez, 
      pffirma, 
      phash,
      NOW()
    );
    
    -- Actualizar registro en ta_15_apremios
    UPDATE public.ta_15_apremios 
    SET clave_practicado = 'F', fecha_actualiz = NOW(), usuario = pcvereg
    WHERE id_control = psec;
    
    RETURN QUERY SELECT 1, 0, 'Firma insertada correctamente';
  END IF;
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT -1, 0, 'Error al insertar firma: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: SP_APREMIOSSVN_FIRMAELECTRONICA_LISTAR_FIRMAS_GENERADAS
-- Tipo: Report
-- Descripción: Lista las firmas generadas para un módulo y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMAELECTRONICA_LISTAR_FIRMAS_GENERADAS(pmod integer, pfec date)
RETURNS TABLE(
  secuencia integer,
  digverificador varchar,
  modulo integer,
  id_modulo integer,
  fechagraba timestamp,
  firmante varchar,
  cargo varchar,
  fecha_firmado varchar,
  hash varchar,
  validez varchar,
  folio integer,
  importe_total numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.secuencia, 
    a.digverificador, 
    a.modulo, 
    a.id_modulo, 
    a.fechagraba, 
    b.firmante, 
    a.cargo, 
    a.fecha_firmado, 
    a.hash,
    a.validez,
    ap.folio,
    COALESCE(ap.importe_global, 0) AS importe_total
  FROM public.tb_fea a
  JOIN public.tb_firmante b ON b.puesto = a.cargo
  LEFT JOIN public.ta_15_apremios ap ON ap.id_control = a.secuencia
  WHERE a.modulo = pmod AND CAST(a.fechagraba AS DATE) = pfec
  ORDER BY a.secuencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================