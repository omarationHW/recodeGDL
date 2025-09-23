-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Prenómina de Ejecutores
-- Archivo: 18_SP_APREMIOSSVN_PRENOMINA_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 2
-- ============================================

-- SP 1/2: SP_APREMIOSSVN_GET_RECAUDADORAS_PRENOMINA
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras activas para prenómina.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_RECAUDADORAS_PRENOMINA()
RETURNS TABLE(
    id_rec smallint, 
    nombre text, 
    recaudadora text,
    zona text,
    activa boolean
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
        r.id_rec, 
        r.nombre, 
        r.recaudadora,
        z.zona,
        CASE WHEN r.estado = 'A' THEN true ELSE false END as activa
    FROM public.ta_12_recaudadoras r
    LEFT JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    WHERE r.id_rec < 8 AND (r.estado = 'A' OR r.estado IS NULL)
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: SP_APREMIOSSVN_PRENOMINA_REPORT
-- Tipo: Report
-- Descripción: Genera el reporte de prenómina de ejecutores entre fechas y recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PRENOMINA_REPORT(
  p_fecha_desde date,
  p_fecha_hasta date,
  p_recaudadora_desde smallint,
  p_recaudadora_hasta smallint
)
RETURNS TABLE(
  zona smallint,
  ejecutor smallint,
  fec_rfc date,
  ini_rfc varchar,
  hom_rfc varchar,
  nombre varchar,
  gastos numeric,
  cuantos bigint,
  recaudadora varchar,
  zona_nombre varchar,
  comision numeric,
  total_comision numeric,
  importe_bruto numeric,
  importe_neto numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      b.id_rec as zona,
      a.ejecutor,
      b.fec_rfc,
      b.ini_rfc,
      b.hom_rfc,
      b.nombre,
      COALESCE(SUM(a.importe_gastos), 0) as gastos,
      COUNT(*) as cuantos,
      c.recaudadora,
      d.zona as zona_nombre,
      COALESCE(b.comision, 0) as comision,
      COALESCE(SUM(a.importe_gastos) * (COALESCE(b.comision, 0) / 100), 0) as total_comision,
      COALESCE(SUM(a.importe_global), 0) as importe_bruto,
      COALESCE(SUM(a.importe_pago), 0) as importe_neto
    FROM public.ta_15_apremios a
    JOIN public.ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec
    JOIN public.ta_12_recaudadoras c ON b.id_rec = c.id_rec
    LEFT JOIN public.ta_12_zonas d ON c.id_zona = d.id_zona
    WHERE a.fecha_pago >= p_fecha_desde
      AND a.fecha_pago <= p_fecha_hasta
      AND a.vigencia = '2'
      AND a.clave_practicado = 'P'
      AND b.id_rec BETWEEN p_recaudadora_desde AND p_recaudadora_hasta
    GROUP BY 
      b.id_rec, 
      a.ejecutor, 
      b.fec_rfc, 
      b.ini_rfc, 
      b.hom_rfc, 
      b.nombre, 
      c.recaudadora, 
      d.zona,
      b.comision
    ORDER BY b.id_rec, a.ejecutor;
END;
$$ LANGUAGE plpgsql;

-- ============================================