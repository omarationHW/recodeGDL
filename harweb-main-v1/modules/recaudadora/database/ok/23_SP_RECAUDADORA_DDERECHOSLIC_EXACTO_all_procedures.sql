-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: dderechosLic (Descuentos Derechos Licencias)
-- Generado: 2025-08-26 23:58:23
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca licencia por folio y retorna datos principales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_licencia(p_folio INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      l.id_licencia, 
      l.licencia,
      (SELECT MIN(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_licencia = l.id_licencia 
         AND d.derechos > 0 
         AND d.cvepago = 0) AS min,
      (SELECT MAX(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_licencia = l.id_licencia 
         AND d.derechos > 0 
         AND d.cvepago = 0 
         AND d.axo <= EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM public.licencias l
    JOIN public.saldos_lic s ON l.id_licencia = s.id_licencia
    WHERE l.licencia = p_folio 
      AND s.derechos > 0 
      AND l.vigente = 'V' 
      AND COALESCE(l.bloqueado, 0) = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca anuncio por folio y retorna datos principales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_anuncio(p_folio INTEGER)
RETURNS TABLE(id_anuncio INTEGER, anuncio INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      l.id_anuncio, 
      l.anuncio,
      (SELECT MIN(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_anuncio = l.id_anuncio 
         AND d.derechos > 0 
         AND d.cvepago = 0) AS min,
      (SELECT MAX(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_anuncio = l.id_anuncio 
         AND d.derechos > 0 
         AND d.cvepago = 0 
         AND d.axo <= EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      (SELECT propietario 
       FROM public.licencias 
       WHERE id_licencia = l.id_licencia) AS propietario
    FROM public.anuncios l
    JOIN public.saldos_lic s ON l.id_licencia = s.id_licencia
    WHERE l.anuncio = p_folio 
      AND s.anuncios > 0 
      AND l.vigente = 'V' 
      AND (l.bloqueado IS NULL OR l.bloqueado = 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_buscar_forma
-- Tipo: Catalog
-- Descripción: Busca formas por folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_forma(p_folio INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      l.id_licencia, 
      l.licencia,
      (SELECT MIN(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_licencia = l.id_licencia 
         AND d.forma > 0 
         AND d.cvepago = 0) AS min,
      (SELECT MAX(d.axo) 
       FROM public.detsal_lic d 
       WHERE d.id_licencia = l.id_licencia 
         AND d.forma > 0 
         AND d.cvepago = 0 
         AND d.axo <= EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM public.licencias l
    JOIN public.saldos_lic s ON l.id_licencia = s.id_licencia
    WHERE l.licencia = p_folio 
      AND s.formas > 0 
      AND l.vigente = 'V' 
      AND l.bloqueado = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_buscar_campania
-- Tipo: Catalog
-- Descripción: Busca campañas de descuento vigentes para derechos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_campania(p_fecha DATE)
RETURNS TABLE(cveautoriza INTEGER, descripcion TEXT, nombre TEXT, porcentajetope INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      c.cveautoriza, 
      c.descripcion, 
      c.nombre, 
      c.porcentajetope
    FROM public.c_autdescmul c
    WHERE c.vigencia = 'V' 
      AND (c.fecha_inicio <= p_fecha AND c.fecha_fin >= p_fecha);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_buscar_descuento
-- Tipo: Catalog
-- Descripción: Busca descuentos vigentes para licencia/anuncio/forma
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_descuento(p_tipo TEXT, p_folio INTEGER)
RETURNS TABLE(
  id_descto INTEGER, 
  tipo TEXT, 
  licencia INTEGER, 
  porcentaje INTEGER, 
  fecalta DATE, 
  captalta TEXT, 
  fecbaja DATE, 
  captbaja TEXT, 
  estado TEXT, 
  cvepago INTEGER, 
  axoini INTEGER, 
  axofin INTEGER, 
  autoriza INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      d.id_descto, d.tipo, d.licencia, d.porcentaje, d.fecalta, 
      d.captalta, d.fecbaja, d.captbaja, d.estado, d.cvepago, 
      d.axoini, d.axofin, d.autoriza
    FROM public.descderlic d
    WHERE d.tipo = p_tipo 
      AND d.licencia = p_folio 
      AND d.estado = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_alta_descuento
-- Tipo: CRUD
-- Descripción: Da de alta un nuevo descuento para licencia/anuncio/forma
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_descuento(
  p_tipo TEXT, 
  p_licencia INTEGER, 
  p_porcentaje INTEGER, 
  p_axoini INTEGER, 
  p_axofin INTEGER, 
  p_autoriza INTEGER, 
  p_user TEXT
)
RETURNS TABLE(result TEXT) AS $$
DECLARE
  v_id INTEGER;
BEGIN
  INSERT INTO public.descderlic (
    tipo, licencia, porcentaje, fecalta, captalta, fecbaja, 
    captbaja, estado, cvepago, axoini, axofin, autoriza
  )
  VALUES (
    p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_user, 
    NULL, NULL, 'V', NULL, p_axoini, p_axofin, p_autoriza
  )
  RETURNING id_descto INTO v_id;
  
  RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_cancelar_descuento
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelar_descuento(
  p_id_descto INTEGER, 
  p_licencia INTEGER, 
  p_user TEXT
)
RETURNS TABLE(result TEXT) AS $$
BEGIN
  UPDATE public.descderlic
  SET estado = 'C', 
      fecbaja = CURRENT_DATE, 
      captbaja = p_user
  WHERE licencia = p_licencia 
    AND id_descto = p_id_descto;
  
  RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_reporte_edocta_lic
-- Tipo: Report
-- Descripción: Reporte de estado de cuenta de licencia/anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_reporte_edocta_lic(p_tipo TEXT, p_numero INTEGER)
RETURNS TABLE(
  concepto TEXT,
  importe NUMERIC,
  periodo TEXT,
  propietario TEXT,
  ubicacion TEXT,
  giro TEXT,
  actividad TEXT
) AS $$
BEGIN
  -- Reporte de estado de cuenta según tipo (L=Licencia, A=Anuncio)
  RETURN QUERY
    SELECT 
      'Derechos'::TEXT AS concepto,
      SUM(s.derechos) AS importe,
      CONCAT(s.axoini, '-', s.axofin) AS periodo,
      s.propietario,
      s.ubicacion,
      s.giro,
      s.actividad
    FROM public.saldos_lic s
    WHERE (CASE 
             WHEN p_tipo = 'L' THEN s.id_licencia = p_numero 
             ELSE s.id_anuncio = p_numero 
           END)
    GROUP BY s.axoini, s.axofin, s.propietario, s.ubicacion, s.giro, s.actividad
    ORDER BY s.axoini;
END;
$$ LANGUAGE plpgsql;

-- ============================================