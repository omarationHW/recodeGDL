-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Pagos_Cons_Cont
-- Generado: 2025-08-27 14:58:54
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_pagos_cons_cont_buscar_pagos
-- Tipo: Report
-- Descripción: Devuelve los pagos de un contrato específico con status 'P' (pagado).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_cons_cont_buscar_pagos(p_control_contrato INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago DATE,
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
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion,
           a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, c.recaudadora, a.caja, a.consec_operacion, a.folio_rcbo
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE a.control_contrato = p_control_contrato
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_pagos_cons_cont_edocuenta
-- Tipo: Report
-- Descripción: Genera el Edo. de Cuenta en PDF y retorna la URL o base64 (simulado, debe integrarse con un sistema de reportes real).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_cons_cont_edocuenta(p_control_contrato INTEGER)
RETURNS TABLE (pdf_url TEXT) AS $$
BEGIN
    -- Aquí se integraría con un sistema de reportes tipo Jasper, Crystal, etc.
    -- Por ahora, retorna una URL simulada
    RETURN QUERY SELECT '/storage/edocuenta/edocuenta_' || p_control_contrato || '.pdf';
END;
$$ LANGUAGE plpgsql;

-- ============================================

