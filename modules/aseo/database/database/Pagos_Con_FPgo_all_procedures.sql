-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Pagos_Con_FPgo
-- Generado: 2025-08-27 15:02:16
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_pagos_con_fpgo_get_pagos_by_fecha
-- Tipo: Report
-- Descripción: Obtiene todos los pagos realizados en una fecha específica (por fecha_hora_pago, status_vigencia = 'P')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_pagos_by_fecha(p_fecha DATE)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago VARCHAR,
    ctrol_operacion INTEGER,
    descripcion VARCHAR,
    exedencias SMALLINT,
    importe NUMERIC,
    status_vigencia VARCHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_contrato,
        to_char(a.aso_mes_pago, 'YYYY-MM') as aso_mes_pago,
        a.ctrol_operacion,
        b.descripcion,
        a.exedencias,
        a.importe,
        a.status_vigencia,
        a.fecha_hora_pago,
        a.id_rec,
        c.recaudadora,
        a.caja,
        a.consec_operacion,
        a.folio_rcbo
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE DATE(a.fecha_hora_pago) = p_fecha
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_pagos_con_fpgo_get_contrato_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de un contrato por control_contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_contrato_detalle(p_control_contrato INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    costo_unidad NUMERIC,
    aso_mes_oblig VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_contrato,
        a.num_contrato,
        a.ctrol_aseo,
        c.tipo_aseo,
        c.descripcion,
        a.ctrol_recolec,
        a.cantidad_recolec,
        b.costo_unidad,
        to_char(a.aso_mes_oblig, 'YYYY-MM') as aso_mes_oblig
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN ta_16_tipo_aseo c ON c.ctrol_aseo = a.ctrol_aseo
    WHERE a.control_contrato = p_control_contrato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_pagos_con_fpgo_get_tipo_aseo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_tipo_aseo_catalog()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

