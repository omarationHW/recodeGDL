-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: GBaja (EXACTO del archivo original)
-- Archivo: 10_SP_OTRASOBLIG_GBAJA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: spcob34_gdatosg_02
-- Tipo: Catalog
-- Descripción: Obtiene los datos generales de una concesión por tabla y control
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spcob34_gdatosg_02(par_tab integer, par_control text)
RETURNS TABLE (
  status integer,
  concepto_status text,
  id_datos integer,
  concesionario text,
  ubicacion text,
  nomcomercial text,
  lugar text,
  obs text,
  adicionales text,
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
  giro integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      CASE WHEN d.id_34_datos IS NULL THEN -1 ELSE 1 END AS status,
      CASE WHEN d.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
      d.id_34_datos, d.concesionario, d.ubicacion, d.nom_comercial, d.lugar, d.obs, d.adicionales,
      s.descripcion AS statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector,
      d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.zona, d.licencia, d.giro
    FROM otrasoblig.t34_datos d
    LEFT JOIN otrasoblig.t34_status s ON d.id_stat = s.id_34_stat
    WHERE d.cve_tab = par_tab::integer AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: spcob34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de una concesión para un periodo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spcob34_gdetade_01(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
  concepto text,
  axo integer,
  mes integer,
  importe_pagar numeric,
  recargos_pagar numeric,
  dscto_importe numeric,
  dscto_recargos numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT c.concepto, c.axo, c.mes, c.importe_pagar, c.recargos_pagar, c.dscto_importe, c.dscto_recargos
    FROM otrasoblig.t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: spcob34_gtotade_01
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos por concepto para una concesión y periodo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spcob34_gtotade_01(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
  cuenta integer,
  obliga text,
  concepto text,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT c.cuenta, c.obliga, c.concepto, SUM(c.importe_pagar + c.recargos_pagar - c.dscto_importe - c.dscto_recargos) as importe
    FROM otrasoblig.t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes
    GROUP BY c.cuenta, c.obliga, c.concepto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: spcob34_gpagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para una concesión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spcob34_gpagados(p_Control integer)
RETURNS TABLE (
  id_34_pagos integer,
  id_datos integer,
  periodo date,
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
    FROM otrasoblig.t34_pagos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat AND b.cve_stat = 'P'
    WHERE a.id_datos = p_Control
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: del34_gen_contrato
-- Tipo: CRUD
-- Descripción: Aplica la baja/cancelación de una concesión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION del34_gen_contrato(par_tabla integer, par_id_34_datos integer, par_Axo_Fin integer, par_Mes_Fin integer, par_usuario text)
RETURNS TABLE (
  status integer,
  concepto_status text
) AS $$
DECLARE
  v_exists integer;
BEGIN
  -- Validar si existe el registro y está vigente
  SELECT COUNT(*) INTO v_exists FROM otrasoblig.t34_datos WHERE id_34_datos = par_id_34_datos AND cve_tab = par_tabla AND id_stat IN (SELECT id_34_stat FROM otrasoblig.t34_status WHERE descripcion = 'VIGENTE');
  IF v_exists = 0 THEN
    RETURN QUERY SELECT -1, 'No existe registro vigente para cancelar';
    RETURN;
  END IF;
  -- Validar que no existan adeudos pendientes
  IF EXISTS (
    SELECT 1 FROM otrasoblig.t34_conceptos WHERE id_datos = par_id_34_datos AND (axo > par_Axo_Fin OR (axo = par_Axo_Fin AND mes > par_Mes_Fin)) AND importe_pagar > 0
  ) THEN
    RETURN QUERY SELECT -2, 'No es posible dar de baja, existen adeudos posteriores';
    RETURN;
  END IF;
  -- Actualizar registro a cancelado
  UPDATE otrasoblig.t34_datos SET id_stat = (SELECT id_34_stat FROM otrasoblig.t34_status WHERE descripcion = 'CANCELADO'), fecha_fin = make_date(par_Axo_Fin, par_Mes_Fin, 1), usuario_baja = par_usuario WHERE id_34_datos = par_id_34_datos;
  RETURN QUERY SELECT 1, 'Se ejecutó correctamente la cancelación del Local/Concesión';
END;
$$ LANGUAGE plpgsql;

-- ============================================