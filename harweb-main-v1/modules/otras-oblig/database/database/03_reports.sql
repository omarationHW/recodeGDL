CREATE OR REPLACE FUNCTION sp34_padron(par_tabla integer, par_vigencia text)
RETURNS TABLE(
    control varchar,
    concesionario varchar,
    ubicacion varchar,
    nomcomercial varchar,
    lugar varchar,
    obs varchar,
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
    id_34_datos integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.ubicacion,
        a.nomcomercial,
        a.lugar,
        a.obs,
        b.descripcion as statusregistro,
        a.unidades,
        a.categoria,
        a.seccion,
        a.bloque,
        a.sector,
        a.superficie,
        a.fecha_inicio as fechainicio,
        a.fecha_fin as fechafin,
        a.id_recaudadora as recaudadora,
        a.id_zona as zona,
        a.licencia,
        a.giro,
        a.tipoobligacion,
        a.id_34_datos
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tabla
      AND (
        par_vigencia = 'TODOS' OR b.descripcion = par_vigencia
      )
    ORDER BY a.control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_busca(par_tab TEXT, par_control TEXT)
RETURNS TABLE(
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    sector TEXT,
    zona INTEGER,
    licencia INTEGER,
    unidades TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.control, d.concesionario, d.ubicacion, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.sector, d.id_zona, d.licencia, u.descripcion as unidades
    FROM t34_datos d
    LEFT JOIN t34_unidades u ON u.cve_tab = d.cve_tab
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_detalle(par_tab TEXT, par_control TEXT, par_rep TEXT, par_fecha TEXT)
RETURNS TABLE(
    concepto TEXT,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multas NUMERIC,
    importe_actualizacion NUMERIC,
    importe_gastos NUMERIC
) AS $$
DECLARE
    v_id_datos INTEGER;
    v_ano INTEGER;
    v_mes INTEGER;
BEGIN
    SELECT id_34_datos INTO v_id_datos FROM t34_datos WHERE cve_tab = par_tab AND control = par_control LIMIT 1;
    IF v_id_datos IS NULL THEN
        RETURN;
    END IF;
    v_ano := split_part(par_fecha, '-', 1)::INTEGER;
    v_mes := split_part(par_fecha, '-', 2)::INTEGER;
    RETURN QUERY
    SELECT c.concepto, c.importe_adeudos, c.importe_recargos, c.importe_multa, c.importe_actualizacion, c.importe_gastos
    FROM t34_conceptos c
    WHERE c.id_datos = v_id_datos
      AND (c.anio < v_ano OR (c.anio = v_ano AND c.mes <= v_mes))
    ORDER BY c.anio, c.mes;
END;
$$ LANGUAGE plpgsql;

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
  FROM adeudos_totales d
  WHERE d.cve_tab = par_tabla
    AND d.periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tab TEXT, par_control TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT,
    id_datos INTEGER,
    concesionario TEXT,
    ubicacion TEXT,
    nomcomercial TEXT,
    lugar TEXT,
    obs TEXT,
    adicionales TEXT,
    statusregistro TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    sector TEXT,
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    zona INTEGER,
    licencia INTEGER,
    giro INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN d.id_34_datos IS NULL THEN -1 ELSE 1 END AS status,
        CASE WHEN d.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        d.id_34_datos, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales, 
        s.descripcion AS statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.id_zona, d.licencia, d.giro
    FROM t34_datos d
    LEFT JOIN t34_status s ON d.id_stat = s.id_34_stat
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cob34_gdetade_01(par_tabla TEXT, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC,
    actualizacion_pagar NUMERIC,
    multa_pagar NUMERIC,
    dscto_multa NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.concepto, c.axo, c.mes, c.importe_pagar, c.recargos_pagar, c.dscto_importe, c.dscto_recargos, c.actualizacion_pagar, c.multa_pagar, c.dscto_multa
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_pagados(p_Control integer)
RETURNS TABLE(
  id_34_pagos integer,
  id_datos integer,
  periodo timestamp,
  importe numeric,
  recargo numeric,
  fecha_hora_pago timestamp,
  id_recaudadora integer,
  caja text,
  operacion integer,
  folio_recibo text,
  usuario text,
  id_stat integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
  FROM t34_pagos a
  JOIN t34_status b ON b.id_34_stat = a.id_stat AND b.cve_stat = 'P'
  WHERE a.id_datos = p_Control
  ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_adeudos(
  par_tabla integer,
  par_id_datos integer,
  par_aso integer,
  par_mes integer
)
RETURNS TABLE (
  concepto varchar,
  axo integer,
  mes integer,
  importe_pagar numeric,
  recargos_pagar numeric,
  dscto_importe numeric,
  dscto_recargos numeric,
  actualizacion_pagar numeric
) AS $$
BEGIN
  RETURN QUERY SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos, actualizacion_pagar
  FROM cob34_gdetade_01(par_tabla::text, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_totales(
  par_tabla integer,
  par_id_datos integer,
  par_aso integer,
  par_mes integer
)
RETURNS TABLE (
  cuenta integer,
  obliga varchar,
  concepto varchar,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY SELECT cuenta, obliga, concepto, importe
  FROM cob34_gtotade_01(par_tabla::text, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_pagados(
  p_Control integer
)
RETURNS TABLE (
  id_34_pagos integer,
  id_datos integer,
  periodo date,
  importe numeric,
  recargo numeric,
  fecha_hora_pago timestamp,
  id_recaudadora integer,
  caja varchar,
  operacion integer,
  folio_recibo varchar,
  usuario varchar,
  id_stat integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_Control AND b.cve_stat = 'P'
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_con34_gfact_02(
    par_Tab VARCHAR,
    par_Ade VARCHAR,
    Par_Rcgo VARCHAR,
    par_Axo INTEGER,
    par_Mes INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia INTEGER,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control,
        d.concesionario,
        d.superficie,
        u.descripcion AS tipo,
        d.licencia,
        SUM(a.importe) AS importe
    FROM t34_datos d
    JOIN t34_unidades u ON d.cve_tab = u.cve_tab
    JOIN t34_adeudos a ON d.id_34_datos = a.id_datos
    WHERE d.cve_tab = par_Tab
      AND (
        (par_Ade = 'A' AND a.status IN ('ADEUDO', 'PAGADO')) OR
        (par_Ade = 'B' AND a.status = 'ADEUDO') OR
        (par_Ade = 'C' AND a.status = 'PAGADO')
      )
      AND (
        (Par_Rcgo = 'S' AND a.recargo > 0) OR
        (Par_Rcgo = 'N')
      )
      AND a.axo = par_Axo
      AND a.mes = par_Mes
    GROUP BY d.control, d.concesionario, d.superficie, u.descripcion, d.licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_padron(par_tabla integer, par_vigencia text)
RETURNS TABLE(
    id_34_datos integer,
    control text,
    concesionario text,
    ubicacion text,
    nomcomercial text,
    lugar text,
    obs text,
    statusregistro text,
    unidades text,
    categoria text,
    seccion text,
    bloque text,
    sector text,
    superficie numeric,
    fechainicio date,
    fechafin date,
    recaudadora integer,
    zona integer,
    licencia integer,
    giro integer,
    tipoobligacion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, b.descripcion as statusregistro, a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora, a.zona, a.licencia, a.giro, a.tipoobligacion
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tabla
      AND (par_vigencia = 'TODOS' OR b.descripcion = par_vigencia)
    ORDER BY a.control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION con34_gdetade_01(par_tab integer, par_control integer, par_rep text, par_fecha text)
RETURNS TABLE(
    concepto text,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_actualizacion
    FROM t34_adeudos_detalle
    WHERE cve_tab = par_tab
      AND id_34_datos = par_control
      AND rep_tipo = par_rep
      AND periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION con34_1detade_01(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    expression text,
    expression_1 numeric,
    expression_2 numeric
) AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de adeudos vencidos
    RETURN QUERY
    SELECT 
        a.descripcion AS expression,
        a.adeudo AS expression_1,
        a.recargo AS expression_2
    FROM t_adeudos a
    WHERE a.id_34_datos = par_Control
      AND a.tipo_reporte = par_Rep
      AND a.periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION con34_1detade_02(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    expression text,
    expression_1 integer,
    expression_2 numeric,
    expression_3 numeric
) AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de adeudos por periodo
    RETURN QUERY
    SELECT 
        a.descripcion AS expression,
        a.cantidad AS expression_1,
        a.adeudo AS expression_2,
        a.recargo AS expression_3
    FROM t_adeudos_periodo a
    WHERE a.id_34_datos = par_Control
      AND a.tipo_reporte = par_Rep
      AND a.periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION con34_rdetade_021(p_id_datos integer)
RETURNS TABLE(registro integer, axo integer, mes integer, periodo date, importe numeric, recargo numeric) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo, axo, mes, periodo, importe, recargo
  FROM t34_adeudos
  WHERE id_datos = p_id_datos AND status = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_adeudos_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos
    FROM cob34_rdetade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_totales_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    cuenta INTEGER,
    obliga TEXT,
    concepto TEXT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe
    FROM cob34_rtotade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_pagados_by_concesion(p_id_34_datos INTEGER)
RETURNS TABLE(
    id_34_pagos INTEGER,
    id_datos INTEGER,
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC,
    fecha_hora_pago TIMESTAMP,
    id_recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    folio_recibo TEXT,
    usuario TEXT,
    id_stat INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago,
           a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure equivalent for con34_gfact_02
-- Parámetros:
--   p_adeudo_status: 'A' (Adeudos y Pagos), 'B' (Solo Adeudos), 'C' (Solo Pagados)
--   p_adeudo_recargo: 'S' (con recargo), 'N' (sin recargo)
--   p_year: año a consultar
--   p_month: mes a consultar

CREATE OR REPLACE FUNCTION con34_gfact_02(
    p_adeudo_status VARCHAR(1),
    p_adeudo_recargo VARCHAR(1),
    p_year INTEGER,
    p_month INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia VARCHAR,
    importe NUMERIC
) AS $$
BEGIN
    -- Ejemplo: la lógica real debe ajustarse a la estructura de la base de datos destino
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.superficie,
        a.tipo,
        a.licencia,
        a.importe
    FROM
        basephp.rastro_facturacion a
    WHERE
        (p_adeudo_status = 'A' OR (p_adeudo_status = 'B' AND a.pagado = false) OR (p_adeudo_status = 'C' AND a.pagado = true))
        AND (p_adeudo_recargo = 'N' OR (p_adeudo_recargo = 'S' AND a.recargo = true))
        AND a.anio = p_year
        AND a.mes = p_month;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION sp_rpagados_get_pagados_by_control(p_control integer)
RETURNS TABLE (
    id_34_pagos integer,
    id_datos integer,
    periodo date,
    importe numeric,
    recargo numeric,
    fecha_hora_pago timestamp,
    id_recaudadora integer,
    caja varchar(2),
    operacion integer,
    folio_recibo varchar(15),
    usuario varchar(10),
    id_stat integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_control
      AND b.cve_stat IN ('P','S','R','D')
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure/function for adeudos
CREATE OR REPLACE FUNCTION con34_1detade_01(
    par_Control integer,
    par_Rep varchar,
    par_Fecha varchar
)
RETURNS TABLE (
    expression text,
    expression_1 numeric,
    expression_2 numeric
) AS $$
BEGIN
    -- Simulación: Debe reemplazarse por la lógica real de cálculo de adeudos y recargos
    -- Ejemplo de consulta:
    RETURN QUERY
    SELECT 
        'Adeudo periodo ' || par_Fecha AS expression,
        ROUND(random()*1000,2) AS expression_1, -- Monto adeudo
        ROUND(random()*200,2) AS expression_2   -- Monto recargo
    FROM generate_series(1, 3);
    -- En producción, reemplazar por la consulta real de adeudos para la concesión y periodo
END;
$$ LANGUAGE plpgsql;
