-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: GConsulta2
-- Generado: 2025-08-28 13:11:34
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_gconsulta2_get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de campos para la tabla seleccionada
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gconsulta2_get_etiquetas(par_tab integer)
RETURNS TABLE (
  cve_tab varchar,
  abreviatura varchar,
  etiq_control varchar,
  concesionario varchar,
  ubicacion varchar,
  superficie varchar,
  fecha_inicio varchar,
  fecha_fin varchar,
  recaudadora varchar,
  sector varchar,
  zona varchar,
  licencia varchar,
  fecha_cancelacion varchar,
  unidad varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  nombre_comercial varchar,
  lugar varchar,
  obs varchar
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_gconsulta2_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene el nombre y descripción de la tabla seleccionada
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gconsulta2_get_tablas(par_tab integer)
RETURNS TABLE (
  cve_tab varchar,
  nombre varchar,
  descripcion varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab::text
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_gconsulta2_busca_coincide
-- Tipo: CRUD
-- Descripción: Busca controles coincidentes según el tipo de búsqueda y dato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_coincide(
  par_tab integer,
  tipo_busqueda integer,
  dato_busqueda varchar
)
RETURNS TABLE (control varchar) AS $$
BEGIN
  IF tipo_busqueda < 4 THEN
    RETURN QUERY EXECUTE format(
      'SELECT control FROM t34_datos WHERE cve_tab = %L AND %I ILIKE %L ORDER BY control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 1 THEN 'control'
        WHEN 2 THEN 'concesionario'
        WHEN 3 THEN 'ubicacion'
      END,
      '%' || dato_busqueda || '%'
    );
  ELSE
    RETURN QUERY EXECUTE format(
      'SELECT a.control FROM t34_datos a JOIN t34_conceptos c ON c.id_datos = a.id_34_datos WHERE a.cve_tab = %L AND c.tipo = %L AND c.concepto ILIKE %L ORDER BY a.control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'L'
        WHEN 6 THEN 'O'
      END,
      '%' || dato_busqueda || '%'
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_gconsulta2_busca_cont
-- Tipo: CRUD
-- Descripción: Busca los datos principales de un control
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_cont(
  par_tab integer,
  par_control varchar
)
RETURNS TABLE (
  status integer,
  concepto_status varchar,
  id_datos integer,
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
  giro integer
) AS $$
BEGIN
  RETURN QUERY SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab::text, par_control);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_gconsulta2_busca_adeudos
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para un control
-- --------------------------------------------

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

-- ============================================

-- SP 6/7: sp_gconsulta2_busca_totales
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos para un control
-- --------------------------------------------

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

-- ============================================

-- SP 7/7: sp_gconsulta2_busca_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un control
-- --------------------------------------------

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

-- ============================================

