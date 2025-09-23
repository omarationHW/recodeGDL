-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: GAdeudosGral (EXACTO del archivo original)
-- Archivo: 07_SP_OTRASOBLIG_GADEUDOSGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: con34_gcont_01
-- Tipo: Report
-- Descripción: Obtiene el reporte general de adeudos por tabla, opción, año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con34_gcont_01(par_tabla integer, par_ade varchar, par_axo integer, par_mes integer)
RETURNS TABLE(
  control varchar,
  concesionario varchar,
  ubicacion varchar,
  nomcomercial varchar,
  lugar varchar,
  obs varchar,
  adicionales varchar,
  statusregistro varchar,
  unidades varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  sector varchar,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer,
  tipoobligacion varchar,
  adeudos_2007 numeric,
  recargos_2007 numeric,
  total_2007 numeric,
  adeudos_2008 numeric,
  recargos_2008 numeric,
  total_2008 numeric,
  adeudos_2009 numeric,
  recargos_2009 numeric,
  total_2009 numeric,
  adeudos_2010 numeric,
  recargos_2010 numeric,
  total_2010 numeric,
  adeudos_2011 numeric,
  recargos_2011 numeric,
  total_2011 numeric,
  adeudos_2012 numeric,
  recargos_2012 numeric,
  total_2012 numeric,
  adeudos_2013 numeric,
  recargos_2013 numeric,
  total_2013 numeric,
  adeudos_2014 numeric,
  recargos_2014 numeric,
  total_2014 numeric,
  adeudos_2015 numeric,
  recargos_2015 numeric,
  total_2015 numeric,
  adeudos_2016 numeric,
  recargos_2016 numeric,
  total_2016 numeric,
  adeudos_2017 numeric,
  recargos_2017 numeric,
  total_2017 numeric,
  adeudos_2018 numeric,
  recargos_2018 numeric,
  total_2018 numeric,
  total_adeudos numeric,
  total_recargos numeric,
  total_general numeric,
  multas numeric,
  gastos numeric,
  datos_doctos varchar,
  total_pagado numeric,
  primer_adeudo date
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.control, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales, d.statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector, d.superficie, d.fechainicio, d.fechafin, d.recaudadora, d.zona, d.licencia, d.giro, d.tipoobligacion,
    d.adeudos_2007, d.recargos_2007, d.total_2007, d.adeudos_2008, d.recargos_2008, d.total_2008, d.adeudos_2009, d.recargos_2009, d.total_2009, d.adeudos_2010, d.recargos_2010, d.total_2010, d.adeudos_2011, d.recargos_2011, d.total_2011, d.adeudos_2012, d.recargos_2012, d.total_2012, d.adeudos_2013, d.recargos_2013, d.total_2013, d.adeudos_2014, d.recargos_2014, d.total_2014, d.adeudos_2015, d.recargos_2015, d.total_2015, d.adeudos_2016, d.recargos_2016, d.total_2016, d.adeudos_2017, d.recargos_2017, d.total_2017, d.adeudos_2018, d.recargos_2018, d.total_2018,
    d.total_adeudos, d.total_recargos, d.total_general, d.multas, d.gastos, d.datos_doctos, d.total_pagado, d.primer_adeudo
  FROM otrasoblig.adeudos_general d
  WHERE d.cve_tab = par_tabla
    AND (par_ade = 'T' OR d.opcion = par_ade)
    AND (par_axo IS NULL OR d.anio = par_axo)
    AND (par_mes IS NULL OR d.mes = par_mes);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp34_adeudototal
-- Tipo: Report
-- Descripción: Obtiene el resumen total de adeudos por tabla y periodo (año-mes).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_adeudototal(par_tabla integer, par_fecha varchar)
RETURNS TABLE(
  control varchar,
  nombre varchar,
  superficie numeric,
  periodos varchar,
  adeudo numeric,
  recargos numeric,
  desc_recargos numeric,
  multa numeric,
  desc_multa numeric,
  actualizacion numeric,
  gastos numeric,
  forma numeric,
  autorizacion numeric,
  total numeric,
  ubicacion varchar,
  tipo varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.control, d.nombre, d.superficie, d.periodos, d.adeudo, d.recargos, d.desc_recargos, d.multa, d.desc_multa, d.actualizacion, d.gastos, d.forma, d.autorizacion, d.total, d.ubicacion, d.tipo
  FROM otrasoblig.adeudos_totales d
  WHERE d.cve_tab = par_tabla
    AND d.periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: t34_tablas
-- Tipo: Catalog
-- Descripción: Catálogo de tablas/rubros.
-- --------------------------------------------

CREATE TABLE IF NOT EXISTS otrasoblig.t34_tablas (
  cve_tab integer PRIMARY KEY,
  nombre varchar(100),
  descripcion varchar(100)
);

-- ============================================

-- SP 4/4: t34_etiq
-- Tipo: Catalog
-- Descripción: Catálogo de etiquetas de campos por tabla.
-- --------------------------------------------

CREATE TABLE IF NOT EXISTS otrasoblig.t34_etiq (
  cve_tab integer,
  abreviatura varchar(4),
  etiq_control varchar(50),
  concesionario varchar(100),
  ubicacion varchar(100),
  superficie varchar(50),
  fecha_inicio varchar(20),
  fecha_fin varchar(20),
  recaudadora varchar(50),
  sector varchar(20),
  zona varchar(20),
  licencia varchar(20),
  fecha_cancelacion varchar(20),
  unidad varchar(20),
  categoria varchar(20),
  seccion varchar(20),
  bloque varchar(20),
  nombre_comercial varchar(100),
  lugar varchar(100),
  obs varchar(100)
);

-- ============================================