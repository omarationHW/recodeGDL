-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DrecgoTrans (Descuentos Recargos Transmisiones)
-- Generado: 2025-08-27 01:13:21
-- Total SPs: 5
-- ============================================

-- SP 1/5: busca_multa_trans
-- Tipo: Report
-- Descripción: Busca folios de transmisión con recargos pendientes (completa o diferencia)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION busca_multa_trans(p_folio integer, p_tipo text)
RETURNS TABLE(
  folio integer,
  baseimpuesto numeric,
  recargos numeric,
  multas numeric,
  total numeric,
  estado text,
  id_descto integer,
  porcentaje numeric,
  observaciones text
) AS $$
BEGIN
  IF p_tipo = 'completa' THEN
    RETURN QUERY
      SELECT 
        i.folio, i.baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
      FROM public.impuestoTransp i
      LEFT JOIN public.descrectrans dt ON dt.folio = i.folio AND dt.estado = 'V'
      WHERE i.folio = p_folio 
        AND i.recargos > 0 
        AND (i.cvepago = 0 OR i.cvepago IS NULL);
  ELSE
    RETURN QUERY
      SELECT 
        i.foliot as folio, i.importe_base as baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
      FROM public.diferencias_glosa i
      LEFT JOIN public.descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
      WHERE i.foliot = p_folio 
        AND i.recargos > 0 
        AND (i.cvepago = 0 OR i.cvepago IS NULL);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: busca_diferencia_trans
-- Tipo: Report
-- Descripción: Busca diferencias de transmisión con recargos pendientes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION busca_diferencia_trans(p_folio integer)
RETURNS TABLE(
  folio integer,
  baseimpuesto numeric,
  recargos numeric,
  multas numeric,
  total numeric,
  estado text,
  id_descto integer,
  porcentaje numeric,
  observaciones text
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      i.foliot as folio, i.importe_base as baseimpuesto, i.recargos, i.multas, i.total,
      COALESCE(dt.estado, 'V') AS estado,
      dt.id_descto, dt.porcentaje, dt.observaciones
    FROM public.diferencias_glosa i
    LEFT JOIN public.descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
    WHERE i.foliot = p_folio 
      AND i.recargos > 0 
      AND (i.cvepago = 0 OR i.cvepago IS NULL);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: alta_descuento_trans
-- Tipo: CRUD
-- Descripción: Da de alta un descuento en recargos de transmisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION alta_descuento_trans(
  p_folio integer,
  p_porcentaje numeric,
  p_observaciones text,
  p_autoriza integer,
  p_user text
) RETURNS TABLE(result text) AS $$
DECLARE
  v_id integer;
  v_exists integer;
BEGIN
  -- Verificar si ya existe un descuento vigente para este folio
  SELECT COUNT(*) INTO v_exists 
  FROM public.descrectrans 
  WHERE folio = p_folio AND estado = 'V';
  
  IF v_exists > 0 THEN
    -- Cancelar descuentos anteriores vigentes
    UPDATE public.descrectrans 
    SET estado = 'C', 
        fecbaja = CURRENT_DATE, 
        captbaja = p_user
    WHERE folio = p_folio AND estado = 'V';
  END IF;
  
  -- Insertar nuevo descuento
  INSERT INTO public.descrectrans (
    folio, porcentaje, fecalta, captalta, fecbaja, captbaja, 
    estado, cvepago, autoriza, observaciones
  )
  VALUES (
    p_folio, p_porcentaje, CURRENT_DATE, p_user, NULL, NULL, 
    'V', NULL, p_autoriza, p_observaciones
  )
  RETURNING id_descto INTO v_id;
  
  RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: cancelar_descuento_trans
-- Tipo: CRUD
-- Descripción: Cancela un descuento en recargos de transmisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cancelar_descuento_trans(
  p_folio integer,
  p_id_descto integer,
  p_user text
) RETURNS TABLE(result text) AS $$
DECLARE
  v_count integer;
BEGIN
  UPDATE public.descrectrans
  SET estado = 'C', 
      fecbaja = CURRENT_DATE, 
      captbaja = p_user
  WHERE folio = p_folio 
    AND id_descto = p_id_descto 
    AND estado = 'V';
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  IF v_count = 0 THEN
    RAISE EXCEPTION 'No se encontró descuento vigente con folio % e ID %', p_folio, p_id_descto;
  END IF;
  
  RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: get_autorizadores_trans
-- Tipo: Catalog
-- Descripción: Obtiene lista de funcionarios autorizados para descuentos en transmisión según permisos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_autorizadores_trans(p_usuario text)
RETURNS TABLE(
  cveautoriza integer, 
  descripcion text, 
  nombre text, 
  porcentajetope integer
) AS $$
DECLARE
  v_has_permission boolean := false;
BEGIN
  -- Verificar permisos del usuario
  SELECT EXISTS(
    SELECT 1 
    FROM public.autoriza a, public.usuarios b, public.deptos d 
    WHERE a.usuario = p_usuario 
      AND a.num_tag IN (1319, 1320) 
      AND b.usuario = a.usuario 
      AND d.cvedepto = b.cvedepto
  ) INTO v_has_permission;
  
  IF NOT v_has_permission THEN
    -- Usuario sin permisos especiales - solo funcionarios básicos
    RETURN QUERY 
    SELECT c.cveautoriza, c.descripcion, c.nombre, c.porcentajetope 
    FROM public.c_autdescrec c
    WHERE c.funcionario = 'N' AND c.vigencia = 'V'
    ORDER BY c.nombre;
  ELSE
    -- Usuario con permisos especiales - todos los autorizadores
    RETURN QUERY 
    SELECT c.cveautoriza, c.descripcion, c.nombre, c.porcentajetope 
    FROM public.c_autdescrec c
    WHERE c.vigencia = 'V' 
    ORDER BY c.cveautoriza DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================