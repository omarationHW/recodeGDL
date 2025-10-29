-- Stored Procedure: sp_adeudos_pag_ver_adeudos
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos (cuota normal y excedencias) para un contrato, tipo de aseo, año y mes.
-- Generado para formulario: Adeudos_Pag
-- Fecha: 2025-08-27 13:49:54

-- PostgreSQL
CREATE OR REPLACE FUNCTION sp_adeudos_pag_ver_adeudos(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER
)
RETURNS TABLE(
    tipo_operacion TEXT,
    exedencias SMALLINT,
    importe NUMERIC,
    status_vigencia TEXT,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja TEXT,
    consec_operacion INTEGER,
    folio_rcbo TEXT
) AS $$
BEGIN
    -- Cuota Normal
    RETURN QUERY
    SELECT 'CN' AS tipo_operacion, a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, a.caja, a.consec_operacion, a.folio_rcbo
    FROM ta_16_contratos c
    JOIN ta_16_pagos a ON a.control_contrato = c.control_contrato
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND to_char(a.aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
      AND a.ctrol_operacion = (SELECT ctrol_operacion FROM ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1)
      AND (a.status_vigencia = 'V' OR a.status_vigencia = 'P');
    -- Excedencias
    RETURN QUERY
    SELECT 'EXE' AS tipo_operacion, a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, a.caja, a.consec_operacion, a.folio_rcbo
    FROM ta_16_contratos c
    JOIN ta_16_pagos a ON a.control_contrato = c.control_contrato
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND to_char(a.aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
      AND a.ctrol_operacion = (SELECT ctrol_operacion FROM ta_16_operacion WHERE cve_operacion = 'E' LIMIT 1)
      AND (a.status_vigencia = 'V' OR a.status_vigencia = 'P');
END;
$$ LANGUAGE plpgsql;