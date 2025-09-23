-- Stored Procedure: con34_gcont_01
-- Tipo: Report
-- Descripción: Obtiene el reporte general de adeudos por tabla, opción, año y mes.
-- Generado para formulario: GAdeudosGral
-- Fecha: 2025-08-28 12:53:29

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
  FROM adeudos_general d
  WHERE d.cve_tab = par_tabla
    AND (par_ade = 'T' OR d.opcion = par_ade)
    AND (par_axo IS NULL OR d.anio = par_axo)
    AND (par_mes IS NULL OR d.mes = par_mes);
END;
$$ LANGUAGE plpgsql;