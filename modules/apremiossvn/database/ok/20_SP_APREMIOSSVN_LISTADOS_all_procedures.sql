-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Listados y Catálogos
-- Archivo: 20_SP_APREMIOSSVN_LISTADOS_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 8
-- ============================================

-- SP 1/8: SP_APREMIOSSVN_LISTADOS_GET_CLAVES
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de tipo_clave<>4 para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GET_CLAVES()
RETURNS TABLE(
    id_clave integer, 
    tipo_clave smallint, 
    concepto_tipo varchar, 
    clave varchar, 
    descrip varchar
) AS $$
BEGIN
  RETURN QUERY 
  SELECT c.id_clave, c.tipo_clave, c.concepto_tipo, c.clave, c.descrip 
  FROM public.ta_15_claves c 
  WHERE c.tipo_clave <> 4 
  ORDER BY c.tipo_clave, c.clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: SP_APREMIOSSVN_LISTADOS_GET_VIGENCIAS
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de vigencia (tipo_clave=5) para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GET_VIGENCIAS()
RETURNS TABLE(
    id_clave integer, 
    tipo_clave smallint, 
    concepto_tipo varchar, 
    clave varchar, 
    descrip varchar
) AS $$
BEGIN
  RETURN QUERY 
  SELECT c.id_clave, c.tipo_clave, c.concepto_tipo, c.clave, c.descrip 
  FROM public.ta_15_claves c 
  WHERE c.tipo_clave = 5 
  ORDER BY c.clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: SP_APREMIOSSVN_LISTADOS_GET_RECAUDADORAS
-- Tipo: Catalog
-- Descripción: Obtiene todas las recaudadoras para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GET_RECAUDADORAS()
RETURNS TABLE(
    id_rec smallint, 
    id_zona integer, 
    recaudadora varchar, 
    domicilio varchar, 
    tel varchar, 
    recaudador varchar, 
    sector varchar,
    zona varchar,
    estado varchar
) AS $$
BEGIN
  RETURN QUERY 
  SELECT 
    r.id_rec, 
    r.id_zona, 
    r.recaudadora, 
    r.domicilio, 
    r.tel, 
    r.recaudador, 
    r.sector,
    z.zona,
    COALESCE(r.estado, 'A') as estado
  FROM public.ta_12_recaudadoras r
  LEFT JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
  ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: SP_APREMIOSSVN_LISTADOS_GET_EJECUTORES
-- Tipo: Catalog
-- Descripción: Obtiene todos los ejecutores para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GET_EJECUTORES()
RETURNS TABLE(
    id_ejecutor integer,
    cve_eje integer, 
    nombre varchar, 
    id_rec integer,
    recaudadora varchar,
    vigencia varchar,
    fec_rfc date,
    ini_rfc varchar,
    hom_rfc varchar,
    comision numeric
) AS $$
BEGIN
  RETURN QUERY 
  SELECT 
    e.id_ejecutor,
    e.cve_eje, 
    e.nombre, 
    e.id_rec,
    r.recaudadora,
    e.vigencia,
    e.fec_rfc,
    e.ini_rfc,
    e.hom_rfc,
    e.comision
  FROM public.ta_15_ejecutores e
  JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
  ORDER BY e.id_rec, e.nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: SP_APREMIOSSVN_LISTADOS_GET_MODULOS
-- Tipo: Catalog
-- Descripción: Obtiene todos los módulos disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GET_MODULOS()
RETURNS TABLE(
    id_modulo integer,
    descripcion varchar,
    aplicacion varchar,
    activo boolean
) AS $$
BEGIN
  RETURN QUERY 
  SELECT 
    m.id_modulo,
    m.descripcion,
    m.aplicacion,
    COALESCE(m.activo, true) as activo
  FROM public.ta_12_modulos m
  ORDER BY m.id_modulo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: SP_APREMIOSSVN_LISTADOS_GENERAL
-- Tipo: Report
-- Descripción: Genera listados generales de folios con filtros múltiples.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GENERAL(
    p_modulo INTEGER DEFAULT NULL,
    p_recaudadora INTEGER DEFAULT NULL,
    p_ejecutor INTEGER DEFAULT NULL,
    p_vigencia VARCHAR DEFAULT NULL,
    p_clave_practicado VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_folio_desde INTEGER DEFAULT NULL,
    p_folio_hasta INTEGER DEFAULT NULL
) RETURNS TABLE(
    id_control INTEGER,
    folio INTEGER,
    modulo INTEGER,
    modulo_desc VARCHAR,
    zona INTEGER,
    recaudadora VARCHAR,
    ejecutor INTEGER,
    ejecutor_nombre VARCHAR,
    fecha_emision DATE,
    fecha_practicado DATE,
    fecha_pago DATE,
    importe_global NUMERIC,
    importe_pago NUMERIC,
    vigencia VARCHAR,
    vigencia_desc VARCHAR,
    clave_practicado VARCHAR,
    practicado_desc VARCHAR,
    dias_emision INTEGER,
    dias_practicado INTEGER
) AS $$
BEGIN
  RETURN QUERY 
  SELECT 
    a.id_control,
    a.folio,
    a.modulo,
    COALESCE(m.descripcion, 'Módulo ' || a.modulo::text) as modulo_desc,
    a.zona,
    r.recaudadora,
    a.ejecutor,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    a.fecha_emision,
    a.fecha_practicado,
    a.fecha_pago,
    a.importe_global,
    a.importe_pago,
    a.vigencia,
    COALESCE(cv.descrip, a.vigencia) as vigencia_desc,
    a.clave_practicado,
    COALESCE(cp.descrip, a.clave_practicado) as practicado_desc,
    EXTRACT(DAY FROM (CURRENT_DATE - a.fecha_emision))::INTEGER as dias_emision,
    CASE WHEN a.fecha_practicado IS NOT NULL 
         THEN EXTRACT(DAY FROM (CURRENT_DATE - a.fecha_practicado))::INTEGER
         ELSE NULL END as dias_practicado
  FROM public.ta_15_apremios a
  LEFT JOIN public.ta_12_modulos m ON a.modulo = m.id_modulo
  LEFT JOIN public.ta_12_recaudadoras r ON a.zona = r.id_rec
  LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
  LEFT JOIN public.ta_15_claves cv ON a.vigencia = cv.clave AND cv.tipo_clave = 5
  LEFT JOIN public.ta_15_claves cp ON a.clave_practicado = cp.clave AND cp.tipo_clave = 1
  WHERE (p_modulo IS NULL OR a.modulo = p_modulo)
    AND (p_recaudadora IS NULL OR a.zona = p_recaudadora)
    AND (p_ejecutor IS NULL OR a.ejecutor = p_ejecutor)
    AND (p_vigencia IS NULL OR a.vigencia = p_vigencia)
    AND (p_clave_practicado IS NULL OR a.clave_practicado = p_clave_practicado)
    AND (p_fecha_desde IS NULL OR a.fecha_emision >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR a.fecha_emision <= p_fecha_hasta)
    AND (p_folio_desde IS NULL OR a.folio >= p_folio_desde)
    AND (p_folio_hasta IS NULL OR a.folio <= p_folio_hasta)
  ORDER BY a.fecha_emision DESC, a.folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: SP_APREMIOSSVN_LISTADOS_ESTADISTICAS
-- Tipo: Report
-- Descripción: Genera estadísticas de folios por ejecutor y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_ESTADISTICAS(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_recaudadora INTEGER DEFAULT NULL
) RETURNS TABLE(
    recaudadora VARCHAR,
    ejecutor_nombre VARCHAR,
    total_folios BIGINT,
    folios_practicados BIGINT,
    folios_pagados BIGINT,
    folios_cancelados BIGINT,
    importe_total NUMERIC,
    importe_pagado NUMERIC,
    porcentaje_practicados NUMERIC,
    porcentaje_pagados NUMERIC
) AS $$
BEGIN
  RETURN QUERY 
  SELECT 
    r.recaudadora,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    COUNT(*) as total_folios,
    COUNT(*) FILTER (WHERE a.clave_practicado = 'P') as folios_practicados,
    COUNT(*) FILTER (WHERE a.vigencia = '2') as folios_pagados,
    COUNT(*) FILTER (WHERE a.vigencia = '3') as folios_cancelados,
    COALESCE(SUM(a.importe_global), 0) as importe_total,
    COALESCE(SUM(CASE WHEN a.vigencia = '2' THEN a.importe_pago ELSE 0 END), 0) as importe_pagado,
    CASE WHEN COUNT(*) > 0 
         THEN ROUND((COUNT(*) FILTER (WHERE a.clave_practicado = 'P')::NUMERIC / COUNT(*)::NUMERIC) * 100, 2)
         ELSE 0 END as porcentaje_practicados,
    CASE WHEN COUNT(*) FILTER (WHERE a.clave_practicado = 'P') > 0
         THEN ROUND((COUNT(*) FILTER (WHERE a.vigencia = '2')::NUMERIC / COUNT(*) FILTER (WHERE a.clave_practicado = 'P')::NUMERIC) * 100, 2)
         ELSE 0 END as porcentaje_pagados
  FROM public.ta_15_apremios a
  LEFT JOIN public.ta_12_recaudadoras r ON a.zona = r.id_rec
  LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
  WHERE a.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
    AND (p_recaudadora IS NULL OR a.zona = p_recaudadora)
  GROUP BY r.recaudadora, e.nombre
  ORDER BY r.recaudadora, e.nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: SP_APREMIOSSVN_LISTADOS_RESUMEN_DIARIO
-- Tipo: Report
-- Descripción: Genera resumen diario de actividad por fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_RESUMEN_DIARIO(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    fecha DATE,
    folios_emitidos BIGINT,
    folios_practicados BIGINT,
    folios_pagados BIGINT,
    importe_emitido NUMERIC,
    importe_pagado NUMERIC,
    recaudacion_efectiva NUMERIC
) AS $$
BEGIN
  RETURN QUERY 
  SELECT 
    d.fecha,
    COALESCE(e.folios_emitidos, 0) as folios_emitidos,
    COALESCE(p.folios_practicados, 0) as folios_practicados,
    COALESCE(pg.folios_pagados, 0) as folios_pagados,
    COALESCE(e.importe_emitido, 0) as importe_emitido,
    COALESCE(pg.importe_pagado, 0) as importe_pagado,
    COALESCE(pg.importe_pagado, 0) as recaudacion_efectiva
  FROM (
    SELECT generate_series(p_fecha_desde, p_fecha_hasta, '1 day'::interval)::date as fecha
  ) d
  LEFT JOIN (
    SELECT fecha_emision as fecha, COUNT(*) as folios_emitidos, SUM(importe_global) as importe_emitido
    FROM public.ta_15_apremios
    WHERE fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY fecha_emision
  ) e ON d.fecha = e.fecha
  LEFT JOIN (
    SELECT fecha_practicado as fecha, COUNT(*) as folios_practicados
    FROM public.ta_15_apremios
    WHERE fecha_practicado BETWEEN p_fecha_desde AND p_fecha_hasta
      AND clave_practicado = 'P'
    GROUP BY fecha_practicado
  ) p ON d.fecha = p.fecha
  LEFT JOIN (
    SELECT fecha_pago as fecha, COUNT(*) as folios_pagados, SUM(importe_pago) as importe_pagado
    FROM public.ta_15_apremios
    WHERE fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
      AND vigencia = '2'
    GROUP BY fecha_pago
  ) pg ON d.fecha = pg.fecha
  ORDER BY d.fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================