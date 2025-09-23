-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: drecgoLic (Descuentos Recargos Licencias)
-- Generado: 2025-08-27 00:52:37
-- Total SPs: 9
-- ============================================

-- SP 1/9: sp_busca_licencia
-- Tipo: Catalog
-- Descripción: Busca licencia por folio y tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_licencia(p_folio INTEGER, p_tipo VARCHAR) 
RETURNS TABLE(
  id_licencia INTEGER,
  licencia INTEGER,
  min SMALLINT,
  max SMALLINT,
  propietario VARCHAR
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      l.id_licencia, 
      l.licencia,
      (SELECT MIN(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_licencia = l.id_licencia 
         AND d.recargos > 0 
         AND d.cvepago = 0) AS min,
      (SELECT MAX(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_licencia = l.id_licencia 
         AND d.recargos > 0 
         AND d.cvepago = 0 
         AND d.axo <= EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM public.licencias l, public.saldos_lic s
    WHERE l.id_licencia = s.id_licencia 
      AND l.licencia = p_folio 
      AND (s.recargos > 0 OR s.multas > 0) 
      AND l.vigente = 'V' 
      AND l.bloqueado = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/9: sp_busca_anuncio
-- Tipo: Catalog
-- Descripción: Busca anuncio por folio y tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_anuncio(p_folio INTEGER, p_tipo VARCHAR) 
RETURNS TABLE(
  id_anuncio INTEGER,
  anuncio INTEGER,
  propietario VARCHAR,
  min SMALLINT,
  max SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      l.id_anuncio, 
      l.anuncio,
      (SELECT propietario 
       FROM public.licencias 
       WHERE id_licencia = l.id_licencia) AS propietario,
      (SELECT MIN(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_anuncio = l.id_anuncio 
         AND d.recargos > 0 
         AND d.cvepago = 0) AS min,
      (SELECT MAX(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_anuncio = l.id_anuncio 
         AND d.recargos > 0 
         AND d.cvepago = 0 
         AND d.axo <= EXTRACT(YEAR FROM CURRENT_DATE)) AS max
    FROM public.anuncios l, public.saldos_lic s
    WHERE l.id_licencia = s.id_licencia 
      AND l.anuncio = p_folio 
      AND s.recargos > 0 
      AND l.vigente = 'V' 
      AND (l.bloqueado IS NULL OR l.bloqueado = 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/9: sp_busca_descuento
-- Tipo: Catalog
-- Descripción: Busca descuentos de recargos/multas para licencia/anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_descuento(p_id_gral INTEGER, p_tipo VARCHAR) 
RETURNS TABLE(
  id_descto INTEGER,
  tipo VARCHAR,
  licencia INTEGER,
  porcentaje SMALLINT,
  fecalta DATE,
  captalta VARCHAR,
  fecbaja DATE,
  captbaja VARCHAR,
  estado VARCHAR,
  cvepago INTEGER,
  axoini INTEGER,
  axofin INTEGER,
  autoriza SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      d.id_descto, d.tipo, d.licencia, d.porcentaje, d.fecalta, 
      d.captalta, d.fecbaja, d.captbaja, d.estado, d.cvepago, 
      d.axoini, d.axofin, d.autoriza
    FROM public.descreclic d
    WHERE d.licencia = p_id_gral AND d.tipo = p_tipo
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/9: sp_alta_desc_recargo
-- Tipo: CRUD
-- Descripción: Alta de descuento de recargo para licencia/anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_desc_recargo(
  p_tipo VARCHAR, 
  p_licencia INTEGER, 
  p_porcentaje SMALLINT, 
  p_usuario VARCHAR, 
  p_axoini INTEGER, 
  p_axofin INTEGER, 
  p_autoriza SMALLINT, 
  p_minmax VARCHAR
) RETURNS TABLE(id_descto INTEGER) AS $$
DECLARE
  v_id INTEGER;
  v_exists INTEGER;
BEGIN
  -- Verificar si ya existe un descuento vigente para el mismo período
  SELECT COUNT(*) INTO v_exists 
  FROM public.descreclic 
  WHERE licencia = p_licencia 
    AND tipo = p_tipo
    AND estado = 'V'
    AND (
      (p_axoini BETWEEN axoini AND axofin) OR
      (p_axofin BETWEEN axoini AND axofin) OR
      (axoini BETWEEN p_axoini AND p_axofin)
    );
  
  IF v_exists > 0 THEN
    RAISE EXCEPTION 'Ya existe un descuento vigente para este período';
  END IF;
  
  INSERT INTO public.descreclic (
    tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, 
    estado, cvepago, axoini, axofin, autoriza
  )
  VALUES (
    p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 
    'V', NULL, p_axoini, p_axofin, p_autoriza
  )
  RETURNING id_descto INTO v_id;
  
  RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/9: sp_alta_desc_multa
-- Tipo: CRUD
-- Descripción: Alta de descuento de multa para licencia/anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_desc_multa(
  p_tipo VARCHAR, 
  p_licencia INTEGER, 
  p_porcentaje SMALLINT, 
  p_usuario VARCHAR, 
  p_autoriza SMALLINT, 
  p_minmax VARCHAR, 
  p_axoini INTEGER, 
  p_axofin INTEGER
) RETURNS TABLE(id_descto INTEGER) AS $$
DECLARE
  v_id INTEGER;
  v_exists INTEGER;
BEGIN
  -- Verificar si ya existe un descuento vigente
  SELECT COUNT(*) INTO v_exists 
  FROM public.descmultalic 
  WHERE id_licanun = p_licencia 
    AND tipo = p_tipo
    AND vigencia = 'V';
  
  IF v_exists > 0 THEN
    RAISE EXCEPTION 'Ya existe un descuento de multa vigente para esta licencia/anuncio';
  END IF;
  
  INSERT INTO public.descmultalic (
    tipo, id_licanun, porcentaje, fecalta, useralta, fecbaja, userbaja, 
    vigencia, cvepago, folio, autoriza, fecact, useract
  )
  VALUES (
    p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 
    'V', NULL, NULL, p_autoriza, CURRENT_DATE, p_usuario
  )
  RETURNING id_descto INTO v_id;
  
  RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/9: sp_baja_desc_recargo
-- Tipo: CRUD
-- Descripción: Cancela descuento de recargo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_desc_recargo(p_id_descto INTEGER, p_usuario VARCHAR) 
RETURNS VOID AS $$
DECLARE
  v_count INTEGER;
BEGIN
  UPDATE public.descreclic 
  SET estado = 'C', 
      fecbaja = CURRENT_DATE, 
      captbaja = p_usuario 
  WHERE id_descto = p_id_descto 
    AND estado = 'V'; -- Solo cancelar si está vigente
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  IF v_count = 0 THEN
    RAISE EXCEPTION 'No se encontró descuento vigente con ID: %', p_id_descto;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/9: sp_baja_desc_multa
-- Tipo: CRUD
-- Descripción: Cancela descuento de multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_desc_multa(p_id_descto INTEGER, p_usuario VARCHAR) 
RETURNS VOID AS $$
DECLARE
  v_count INTEGER;
BEGIN
  UPDATE public.descmultalic 
  SET vigencia = 'C', 
      fecbaja = CURRENT_DATE, 
      userbaja = p_usuario 
  WHERE id_descto = p_id_descto 
    AND vigencia = 'V'; -- Solo cancelar si está vigente
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  IF v_count = 0 THEN
    RAISE EXCEPTION 'No se encontró descuento vigente con ID: %', p_id_descto;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/9: sp_consulta_permiso
-- Tipo: Catalog
-- Descripción: Consulta permisos de usuario para descuentos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_permiso(p_usuario VARCHAR) 
RETURNS TABLE(
  usuario VARCHAR,
  num_tag INTEGER
) AS $$
BEGIN
  RETURN QUERY 
  SELECT a.usuario, a.num_tag 
  FROM public.autoriza a
  WHERE a.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/9: sp_consulta_funcionarios
-- Tipo: Catalog
-- Descripción: Consulta funcionarios autorizados para descuentos de recargo o multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_funcionarios(p_tipo VARCHAR) 
RETURNS TABLE(
  cveautoriza INTEGER,
  descripcion VARCHAR,
  nombre VARCHAR,
  porcentajetope INTEGER
) AS $$
BEGIN
  IF p_tipo = 'recargo' THEN
    RETURN QUERY 
    SELECT c.cveautoriza, c.descripcion, c.nombre, c.porcentajetope 
    FROM public.c_autdescrec c 
    WHERE c.vigencia = 'V' 
    ORDER BY c.cveautoriza DESC;
  ELSE
    RETURN QUERY 
    SELECT c.cveautoriza, c.descripcion, c.nombre, c.porcentajetope 
    FROM public.c_autdescmul c 
    WHERE c.vigencia = 'V' 
    ORDER BY c.cveautoriza DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================