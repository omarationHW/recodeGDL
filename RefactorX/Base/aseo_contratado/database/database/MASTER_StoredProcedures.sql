-- ============================================
-- SCRIPT MAESTRO DE STORED PROCEDURES
-- Proyecto: aseo
-- Generado: 2025-08-27 20:45:14
-- Total SPs: 11
-- ============================================

-- NOTA: Ejecutar este script en PostgreSQL para crear todos los stored procedures
-- del módulo. Se recomienda ejecutar en el siguiente orden:
-- 1. CATALOG procedures (consultas básicas)
-- 2. CRUD procedures (operaciones de datos)
-- 3. PROCESS procedures (procesos de negocio)
-- 4. REPORT procedures (reportes y análisis)

-- ============================================
-- STORED PROCEDURES TIPO: Catalog
-- ============================================

-- SP 1/4 del tipo Catalog
-- Nombre: sp_get_recaudadoras
-- Descripción: Obtiene el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/4 del tipo Catalog
-- Nombre: sp_get_tipo_aseo
-- Descripción: Obtiene el catálogo de tipos de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/4 del tipo Catalog
-- Nombre: vw_contratos_detalle
-- Descripción: Vista para obtener detalle de contrato por número y tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  c.*, e.descripcion as nom_emp, e.representante, e.domicilio, c.status_vigencia
FROM ta_16_contratos c
JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp;

-- --------------------------------------------

-- SP 4/4 del tipo Catalog
-- Nombre: vw_convenios
-- Descripción: Vista para obtener convenio de un contrato
-- --------------------------------------------

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: CRUD
-- ============================================

-- SP 1/6 del tipo CRUD
-- Nombre: sp_buscar_apremios
-- Descripción: Busca los apremios de un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_apremios(p_control_contrato INTEGER)
RETURNS TABLE(id_control INTEGER, folio INTEGER, importe_multa NUMERIC, importe_recargo NUMERIC, importe_gastos NUMERIC, fecha_emision DATE, fecha_practicado DATE, vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_control, folio, importe_multa, importe_recargo, importe_gastos, fecha_emision, fecha_practicado, vigencia FROM ta_15_apremios WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P' ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/6 del tipo CRUD
-- Nombre: sp_buscar_contrato
-- Descripción: Busca un contrato por número y tipo de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE(control_contrato INTEGER, status_vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT control_contrato, status_vigencia FROM ta_16_contratos WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/6 del tipo CRUD
-- Nombre: sp_buscar_convenio
-- Descripción: Busca el convenio relacionado a un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_convenio(p_idlc INTEGER)
RETURNS TABLE(convenio VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d WHERE a.id_referencia = p_idlc AND a.modulo = 16 AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A' AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 4/6 del tipo CRUD
-- Nombre: sp_buscar_periodos_apremio
-- Descripción: Busca los periodos de un apremio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_periodos_apremio(p_id_apremio INTEGER)
RETURNS TABLE(id_control INTEGER, control_otr INTEGER, ayo SMALLINT, periodo SMALLINT, importe NUMERIC, recargos NUMERIC, cantidad NUMERIC, tipo INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad, tipo FROM ta_15_periodos WHERE control_otr = p_id_apremio ORDER BY ayo, periodo;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 5/6 del tipo CRUD
-- Nombre: sp_pagar_apremio
-- Descripción: Marca un apremio como pagado, actualizando los campos de pago.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_pagar_apremio(
    p_fecha DATE,
    p_id_rec INTEGER,
    p_caja VARCHAR,
    p_operacion INTEGER,
    p_importe_gastos NUMERIC,
    p_id_control INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_15_apremios
    SET fecha_pago = p_fecha,
        recaudadora = p_id_rec,
        caja = p_caja,
        operacion = p_operacion,
        vigencia = '2',
        clave_mov = 'P',
        importe_pago = p_importe_gastos
    WHERE id_control = p_id_control;
END;
$$;

-- --------------------------------------------

-- SP 6/6 del tipo CRUD
-- Nombre: upd16_ade
-- Descripción: Actualiza el estado de adeudo (pagado, condonado, cancelado, prescrito) para un periodo de un contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION upd16_ade(
  p_control_contrato integer,
  p_periodo varchar,
  p_ctrol_oper integer,
  p_vigencia char(1),
  p_fecha date,
  p_reca integer,
  p_caja varchar,
  p_operacion integer,
  p_folio_rcbo varchar,
  p_obs varchar
) RETURNS text AS $$
DECLARE
  v_count integer;
BEGIN
  -- Validar existencia
  SELECT count(*) INTO v_count FROM ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND to_char(aso_mes_pago, 'YYYY-MM') = p_periodo
      AND ctrol_operacion = p_ctrol_oper
      AND status_vigencia = 'V';
  IF v_count = 0 THEN
    RETURN 'No existe adeudo vigente para el periodo';
  END IF;
  -- Actualizar
  UPDATE ta_16_pagos
    SET status_vigencia = p_vigencia,
        fecha_hora_pago = p_fecha,
        id_rec = p_reca,
        caja = p_caja,
        consec_operacion = CASE WHEN p_vigencia = 'P' THEN p_operacion ELSE 0 END,
        folio_rcbo = p_folio_rcbo,
        observaciones = p_obs
    WHERE control_contrato = p_control_contrato
      AND to_char(aso_mes_pago, 'YYYY-MM') = p_periodo
      AND ctrol_operacion = p_ctrol_oper
      AND status_vigencia = 'V';
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: Report
-- ============================================

-- SP 1/1 del tipo Report
-- Nombre: con16_detade_021
-- Descripción: Devuelve los adeudos pendientes de un contrato para la opción múltiple
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con16_detade_021(p_control integer)
RETURNS TABLE (
  expression integer,
  expression_1 varchar,
  expression_2 varchar,
  expression_3 integer,
  expression_4 integer,
  expression_5 numeric,
  expression_6 numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.control_contrato,
    to_char(p.aso_mes_pago, 'YYYY-MM'),
    o.descripcion,
    p.ctrol_operacion,
    p.exedencias,
    p.importe,
    0.0
  FROM ta_16_pagos p
  JOIN ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
  WHERE p.control_contrato = p_control
    AND p.status_vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- FIN DEL SCRIPT MAESTRO
-- Total de 11 stored procedures incluidos
-- ============================================
