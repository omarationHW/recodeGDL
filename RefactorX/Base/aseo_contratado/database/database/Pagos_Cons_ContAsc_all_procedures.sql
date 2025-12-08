-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Pagos_Cons_ContAsc
-- Base de datos: padron_licencias (aseo_contratado)
-- Actualizado: 2025-12-07
-- Total SPs: 2
-- ============================================
-- Descripcion: Consulta de pagos por contrato de forma ascendente
-- Permite navegar entre contratos y ver sus pagos con status P
-- ============================================

-- SP 1/2: sp_aseo_contratos_ascendente
-- Tipo: Report
-- Descripcion: Busca contratos con num_contrato >= al indicado, ordenados ascendentemente
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_contratos_ascendente(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_ascendente(
    p_tipo_aseo_id INTEGER,
    p_num_contrato INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    tipo_aseo_id INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.tipo_aseo_id,
        t.cve_tipo::VARCHAR as tipo_aseo,
        t.descripcion::VARCHAR
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE c.num_contrato >= p_num_contrato
      AND c.tipo_aseo_id = p_tipo_aseo_id
    ORDER BY c.num_contrato ASC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_contratos_ascendente(INTEGER, INTEGER) TO PUBLIC;


-- SP 2/2: sp_aseo_pagos_contrato
-- Tipo: Report
-- Descripcion: Obtiene pagos de un contrato con status P (pagado)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_pagos_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago DATE,
    ctrol_operacion INTEGER,
    descripcion VARCHAR,
    exedencias INTEGER,
    importe NUMERIC,
    status_vigencia VARCHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec INTEGER,
    recaudadora VARCHAR,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.fecha_pago as aso_mes_pago,
        COALESCE(p.recaudadora_id, 0) as ctrol_operacion,
        COALESCE(p.forma_pago, 'PAGO')::VARCHAR as descripcion,
        0::INTEGER as exedencias,
        COALESCE(p.monto, 0) as importe,
        'P'::VARCHAR as status_vigencia,
        p.created_at as fecha_hora_pago,
        COALESCE(p.recaudadora_id, 0) as id_rec,
        COALESCE(r.descripcion, '')::VARCHAR as recaudadora,
        ''::VARCHAR as caja,
        p.pago_id as consec_operacion,
        COALESCE(p.recibo, '')::VARCHAR as folio_rcbo
    FROM ta_16_pagos p
    LEFT JOIN ta_16_recaudadoras r ON r.recaudadora_id = p.recaudadora_id
    WHERE p.control_contrato = p_control_contrato
      AND p.activo = true
    ORDER BY p.control_contrato, p.fecha_pago, p.pago_id;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_pagos_contrato(INTEGER) TO PUBLIC;


-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
