-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Modulo: aseo_contratado - Pagos y Reportes
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 12
-- ============================================

-- ================================================================================
-- SECCION 1: PAGOS
-- ================================================================================

-- ============================================
-- SP 1/12: sp_aseo_pagos_por_forma_pago
-- Descripcion: Consulta pagos agrupados por forma de pago
-- Parametros:
--   p_fecha_desde: Fecha inicial (opcional)
--   p_fecha_hasta: Fecha final (requerida)
--   p_forma_pago: Forma de pago especifica (opcional, null=todas)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_pagos_por_forma_pago(DATE, DATE, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_forma_pago(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT CURRENT_DATE,
    p_forma_pago INTEGER DEFAULT NULL
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    forma_pago INTEGER,
    importe NUMERIC(12,2),
    fecha_hora_pago TIMESTAMP,
    folio_rcbo VARCHAR,
    usuario VARCHAR,
    id_rec INTEGER,
    ctrol_operacion INTEGER,
    descripcion_operacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_contrato,
        c.num_contrato,
        a.aso_mes_pago,
        a.forma_pago,
        a.importe,
        a.fecha_hora_pago,
        a.folio_rcbo,
        a.usuario,
        a.id_rec,
        a.ctrol_operacion,
        co.descripcion as descripcion_operacion
    FROM ta_16_adeudos a
    INNER JOIN ta_16_contratos c ON a.control_contrato = c.control_contrato
    LEFT JOIN ta_16_cves_operacion co ON a.ctrol_operacion = co.ctrol_operacion
    WHERE a.status_vigencia = 'P'
        AND a.fecha_hora_pago IS NOT NULL
        AND (p_fecha_desde IS NULL OR a.fecha_hora_pago::DATE >= p_fecha_desde)
        AND a.fecha_hora_pago::DATE <= p_fecha_hasta
        AND (p_forma_pago IS NULL OR a.forma_pago = p_forma_pago)
    ORDER BY a.fecha_hora_pago DESC, a.forma_pago, c.num_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_pagos_por_forma_pago(DATE, DATE, INTEGER) TO PUBLIC;

-- ============================================
-- SP 2/12: sp_aseo_contrato_consultar
-- Descripcion: Busca un contrato por numero
-- Parametros:
--   p_num_contrato: Numero de contrato
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_contrato_consultar(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_contrato_consultar(
    p_num_contrato INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    contribuyente VARCHAR,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.contribuyente,
        ta.tipo_aseo,
        ta.descripcion
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipos_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    WHERE c.num_contrato = p_num_contrato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_contrato_consultar(INTEGER) TO PUBLIC;

-- ============================================
-- SP 3/12: sp_aseo_pagos_por_contrato
-- Descripcion: Lista pagos de un contrato especifico
-- Parametros:
--   p_control_contrato: Control del contrato
--   p_fecha_desde: Fecha inicial (opcional)
--   p_fecha_hasta: Fecha final (opcional)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_pagos_por_contrato(INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_contrato(
    p_control_contrato INTEGER,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    descripcion VARCHAR,
    importe NUMERIC(12,2),
    fecha_hora_pago TIMESTAMP,
    forma_pago INTEGER,
    folio_rcbo VARCHAR,
    usuario VARCHAR,
    id_rec INTEGER,
    caja VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.aso_mes_pago,
        a.ctrol_operacion,
        co.descripcion,
        a.importe,
        a.fecha_hora_pago,
        a.forma_pago,
        a.folio_rcbo,
        a.usuario,
        a.id_rec,
        a.caja
    FROM ta_16_adeudos a
    LEFT JOIN ta_16_cves_operacion co ON a.ctrol_operacion = co.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato
        AND a.status_vigencia = 'P'
        AND a.fecha_hora_pago IS NOT NULL
        AND (p_fecha_desde IS NULL OR a.fecha_hora_pago::DATE >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR a.fecha_hora_pago::DATE <= p_fecha_hasta)
    ORDER BY a.fecha_hora_pago DESC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_pagos_por_contrato(INTEGER, DATE, DATE) TO PUBLIC;

-- ================================================================================
-- SECCION 2: REPORTES
-- ================================================================================

-- ============================================
-- SP 4/12: sp_aseo_rep_padron_contratos
-- Descripcion: Reporte del padron de contratos
-- Parametros:
--   p_tipo_aseo: Tipo de aseo (opcional)
--   p_status: Status del contrato (opcional)
--   p_empresa: Numero de empresa (opcional)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rep_padron_contratos(INTEGER, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_rep_padron_contratos(
    p_tipo_aseo INTEGER DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL,
    p_empresa INTEGER DEFAULT NULL
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    tipo_aseo VARCHAR,
    descripcion_tipo VARCHAR,
    contribuyente VARCHAR,
    nombre_empresa VARCHAR,
    status_contrato VARCHAR,
    aso_mes_oblig TIMESTAMP,
    cantidad_recolec INTEGER,
    costo_unidad NUMERIC(12,2),
    num_rec INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        ta.tipo_aseo,
        ta.descripcion as descripcion_tipo,
        c.contribuyente,
        e.nom_emp as nombre_empresa,
        c.status_contrato,
        c.aso_mes_oblig,
        c.cantidad_recolec::INTEGER,
        ur.costo_unidad,
        c.num_rec
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipos_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_emp
    LEFT JOIN ta_16_und_recolec ur ON c.ctrol_recolec = ur.ctrol_recolec
    WHERE (p_tipo_aseo IS NULL OR c.ctrol_aseo = p_tipo_aseo)
        AND (p_status IS NULL OR c.status_contrato = p_status)
        AND (p_empresa IS NULL OR c.num_empresa = p_empresa)
    ORDER BY c.num_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rep_padron_contratos(INTEGER, VARCHAR, INTEGER) TO PUBLIC;

-- ============================================
-- SP 5/12: sp_aseo_rep_recaudadoras
-- Descripcion: Reporte de recaudadoras con estadisticas
-- Parametros: ninguno
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rep_recaudadoras();

CREATE OR REPLACE FUNCTION public.sp_aseo_rep_recaudadoras()
RETURNS TABLE (
    num_rec INTEGER,
    descripcion VARCHAR,
    total_contratos BIGINT,
    total_adeudos BIGINT,
    monto_adeudos NUMERIC(12,2),
    total_pagos BIGINT,
    monto_pagos NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.num_rec,
        r.descripcion,
        COUNT(DISTINCT c.control_contrato) as total_contratos,
        COUNT(CASE WHEN a.status_vigencia = 'D' THEN 1 END) as total_adeudos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'D' THEN a.importe ELSE 0 END), 0) as monto_adeudos,
        COUNT(CASE WHEN a.status_vigencia = 'P' THEN 1 END) as total_pagos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'P' THEN a.importe ELSE 0 END), 0) as monto_pagos
    FROM ta_16_recaudadoras r
    LEFT JOIN ta_16_contratos c ON r.num_rec = c.num_rec
    LEFT JOIN ta_16_adeudos a ON c.control_contrato = a.control_contrato
    GROUP BY r.num_rec, r.descripcion
    ORDER BY r.num_rec;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rep_recaudadoras() TO PUBLIC;

-- ============================================
-- SP 6/12: sp_aseo_rep_tipos_aseo
-- Descripcion: Reporte de tipos de aseo con estadisticas
-- Parametros: ninguno
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rep_tipos_aseo();

CREATE OR REPLACE FUNCTION public.sp_aseo_rep_tipos_aseo()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cve_tipo VARCHAR,
    total_contratos BIGINT,
    contratos_vigentes BIGINT,
    contratos_baja BIGINT,
    monto_adeudos NUMERIC(12,2),
    monto_pagos NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ta.ctrol_aseo,
        ta.tipo_aseo,
        ta.descripcion,
        ta.cve_tipo,
        COUNT(DISTINCT c.control_contrato) as total_contratos,
        COUNT(DISTINCT CASE WHEN c.status_contrato = 'V' THEN c.control_contrato END) as contratos_vigentes,
        COUNT(DISTINCT CASE WHEN c.status_contrato = 'B' THEN c.control_contrato END) as contratos_baja,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'D' THEN a.importe ELSE 0 END), 0) as monto_adeudos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'P' THEN a.importe ELSE 0 END), 0) as monto_pagos
    FROM ta_16_tipos_aseo ta
    LEFT JOIN ta_16_contratos c ON ta.ctrol_aseo = c.ctrol_aseo
    LEFT JOIN ta_16_adeudos a ON c.control_contrato = a.control_contrato
    GROUP BY ta.ctrol_aseo, ta.tipo_aseo, ta.descripcion, ta.cve_tipo
    ORDER BY ta.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rep_tipos_aseo() TO PUBLIC;

-- ============================================
-- SP 7/12: sp_aseo_rep_zonas
-- Descripcion: Reporte de zonas con estadisticas
-- Parametros: ninguno
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rep_zonas();

CREATE OR REPLACE FUNCTION public.sp_aseo_rep_zonas()
RETURNS TABLE (
    ctrol_zona INTEGER,
    cve_zona VARCHAR,
    nombre_zona VARCHAR,
    total_contratos BIGINT,
    monto_adeudos NUMERIC(12,2),
    monto_pagos NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        z.ctrol_zona,
        z.cve_zona,
        z.nombre_zona,
        COUNT(DISTINCT c.control_contrato) as total_contratos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'D' THEN a.importe ELSE 0 END), 0) as monto_adeudos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'P' THEN a.importe ELSE 0 END), 0) as monto_pagos
    FROM ta_16_zonas z
    LEFT JOIN ta_16_contratos c ON z.ctrol_zona = c.ctrol_zona
    LEFT JOIN ta_16_adeudos a ON c.control_contrato = a.control_contrato
    GROUP BY z.ctrol_zona, z.cve_zona, z.nombre_zona
    ORDER BY z.ctrol_zona;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rep_zonas() TO PUBLIC;

-- ============================================
-- SP 8/12: sp_aseo_rpt_adeudos
-- Descripcion: Reporte detallado de adeudos
-- Parametros: Multiples filtros opcionales
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rpt_adeudos(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, NUMERIC);

CREATE OR REPLACE FUNCTION public.sp_aseo_rpt_adeudos(
    p_tipo_aseo INTEGER DEFAULT NULL,
    p_num_empresa INTEGER DEFAULT NULL,
    p_status_contrato VARCHAR DEFAULT NULL,
    p_periodo_desde VARCHAR DEFAULT NULL,
    p_periodo_hasta VARCHAR DEFAULT NULL,
    p_monto_minimo NUMERIC DEFAULT 0
)
RETURNS TABLE (
    num_contrato INTEGER,
    nombre_empresa VARCHAR,
    periodo VARCHAR,
    concepto VARCHAR,
    importe_adeudo NUMERIC(12,2),
    importe_recargo NUMERIC(12,2),
    importe_multa NUMERIC(12,2),
    importe_gastos NUMERIC(12,2),
    total_periodo NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.num_contrato,
        e.nom_emp as nombre_empresa,
        TO_CHAR(a.aso_mes_pago, 'YYYY-MM') as periodo,
        co.descripcion as concepto,
        a.importe as importe_adeudo,
        COALESCE(a.recargo, 0) as importe_recargo,
        COALESCE(a.multa, 0) as importe_multa,
        COALESCE(a.gastos, 0) as importe_gastos,
        (a.importe + COALESCE(a.recargo, 0) + COALESCE(a.multa, 0) + COALESCE(a.gastos, 0)) as total_periodo
    FROM ta_16_adeudos a
    INNER JOIN ta_16_contratos c ON a.control_contrato = c.control_contrato
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_emp
    LEFT JOIN ta_16_cves_operacion co ON a.ctrol_operacion = co.ctrol_operacion
    WHERE a.status_vigencia = 'D'
        AND (p_tipo_aseo IS NULL OR c.ctrol_aseo = p_tipo_aseo)
        AND (p_num_empresa IS NULL OR c.num_empresa = p_num_empresa)
        AND (p_status_contrato IS NULL OR c.status_contrato = p_status_contrato)
        AND (p_periodo_desde IS NULL OR TO_CHAR(a.aso_mes_pago, 'YYYY-MM') >= p_periodo_desde)
        AND (p_periodo_hasta IS NULL OR TO_CHAR(a.aso_mes_pago, 'YYYY-MM') <= p_periodo_hasta)
        AND (a.importe + COALESCE(a.recargo, 0) + COALESCE(a.multa, 0) + COALESCE(a.gastos, 0)) >= p_monto_minimo
    ORDER BY e.nom_emp, c.num_contrato, a.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rpt_adeudos(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, NUMERIC) TO PUBLIC;

-- ============================================
-- SP 9/12: sp_aseo_rpt_contratos
-- Descripcion: Reporte detallado de contratos
-- Parametros: Filtros opcionales
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rpt_contratos(INTEGER, VARCHAR, DATE, DATE);

CREATE OR REPLACE FUNCTION public.sp_aseo_rpt_contratos(
    p_tipo_aseo INTEGER DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    tipo_aseo VARCHAR,
    contribuyente VARCHAR,
    nombre_empresa VARCHAR,
    status_contrato VARCHAR,
    aso_mes_oblig TIMESTAMP,
    cantidad_recolec INTEGER,
    costo_unidad NUMERIC(12,2),
    total_adeudos BIGINT,
    monto_adeudos NUMERIC(12,2),
    total_pagos BIGINT,
    monto_pagos NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        ta.tipo_aseo,
        c.contribuyente,
        e.nom_emp as nombre_empresa,
        c.status_contrato,
        c.aso_mes_oblig,
        c.cantidad_recolec::INTEGER,
        ur.costo_unidad,
        COUNT(CASE WHEN a.status_vigencia = 'D' THEN 1 END) as total_adeudos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'D' THEN a.importe ELSE 0 END), 0) as monto_adeudos,
        COUNT(CASE WHEN a.status_vigencia = 'P' THEN 1 END) as total_pagos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'P' THEN a.importe ELSE 0 END), 0) as monto_pagos
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipos_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_emp
    LEFT JOIN ta_16_und_recolec ur ON c.ctrol_recolec = ur.ctrol_recolec
    LEFT JOIN ta_16_adeudos a ON c.control_contrato = a.control_contrato
    WHERE (p_tipo_aseo IS NULL OR c.ctrol_aseo = p_tipo_aseo)
        AND (p_status IS NULL OR c.status_contrato = p_status)
        AND (p_fecha_desde IS NULL OR c.aso_mes_oblig::DATE >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR c.aso_mes_oblig::DATE <= p_fecha_hasta)
    GROUP BY c.control_contrato, c.num_contrato, ta.tipo_aseo, c.contribuyente,
             e.nom_emp, c.status_contrato, c.aso_mes_oblig, c.cantidad_recolec, ur.costo_unidad
    ORDER BY c.num_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rpt_contratos(INTEGER, VARCHAR, DATE, DATE) TO PUBLIC;

-- ============================================
-- SP 10/12: sp_aseo_rpt_empresas
-- Descripcion: Reporte de empresas con estadisticas
-- Parametros:
--   p_tipo_empresa: Tipo de empresa (opcional)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rpt_empresas(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_rpt_empresas(
    p_tipo_empresa INTEGER DEFAULT NULL
)
RETURNS TABLE (
    num_emp INTEGER,
    nom_emp VARCHAR,
    tipo_emp VARCHAR,
    total_contratos BIGINT,
    contratos_vigentes BIGINT,
    total_adeudos BIGINT,
    monto_adeudos NUMERIC(12,2),
    total_pagos BIGINT,
    monto_pagos NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_emp,
        e.nom_emp,
        te.descripcion as tipo_emp,
        COUNT(DISTINCT c.control_contrato) as total_contratos,
        COUNT(DISTINCT CASE WHEN c.status_contrato = 'V' THEN c.control_contrato END) as contratos_vigentes,
        COUNT(CASE WHEN a.status_vigencia = 'D' THEN 1 END) as total_adeudos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'D' THEN a.importe ELSE 0 END), 0) as monto_adeudos,
        COUNT(CASE WHEN a.status_vigencia = 'P' THEN 1 END) as total_pagos,
        COALESCE(SUM(CASE WHEN a.status_vigencia = 'P' THEN a.importe ELSE 0 END), 0) as monto_pagos
    FROM ta_16_empresas e
    LEFT JOIN ta_16_tipos_emp te ON e.tipo_emp = te.tipo_emp
    LEFT JOIN ta_16_contratos c ON e.num_emp = c.num_empresa
    LEFT JOIN ta_16_adeudos a ON c.control_contrato = a.control_contrato
    WHERE (p_tipo_empresa IS NULL OR e.tipo_emp = p_tipo_empresa)
    GROUP BY e.num_emp, e.nom_emp, te.descripcion
    ORDER BY e.nom_emp;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rpt_empresas(INTEGER) TO PUBLIC;

-- ============================================
-- SP 11/12: sp_aseo_rpt_estado_cuenta
-- Descripcion: Estado de cuenta de un contrato
-- Parametros:
--   p_control_contrato: Control del contrato
--   p_fecha_hasta: Fecha limite (opcional)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rpt_estado_cuenta(INTEGER, DATE);

CREATE OR REPLACE FUNCTION public.sp_aseo_rpt_estado_cuenta(
    p_control_contrato INTEGER,
    p_fecha_hasta DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    tipo_movimiento VARCHAR,
    fecha TIMESTAMP,
    periodo VARCHAR,
    concepto VARCHAR,
    importe NUMERIC(12,2),
    recargo NUMERIC(12,2),
    multa NUMERIC(12,2),
    gastos NUMERIC(12,2),
    total NUMERIC(12,2),
    status VARCHAR,
    folio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN a.status_vigencia = 'D' THEN 'ADEUDO'
            WHEN a.status_vigencia = 'P' THEN 'PAGO'
            WHEN a.status_vigencia = 'S' THEN 'CONDONADO'
            ELSE 'OTRO'
        END as tipo_movimiento,
        COALESCE(a.fecha_hora_pago, a.aso_mes_pago) as fecha,
        TO_CHAR(a.aso_mes_pago, 'YYYY-MM') as periodo,
        co.descripcion as concepto,
        a.importe,
        COALESCE(a.recargo, 0) as recargo,
        COALESCE(a.multa, 0) as multa,
        COALESCE(a.gastos, 0) as gastos,
        (a.importe + COALESCE(a.recargo, 0) + COALESCE(a.multa, 0) + COALESCE(a.gastos, 0)) as total,
        a.status_vigencia as status,
        a.folio_rcbo as folio
    FROM ta_16_adeudos a
    LEFT JOIN ta_16_cves_operacion co ON a.ctrol_operacion = co.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato
        AND (a.fecha_hora_pago IS NULL OR a.fecha_hora_pago::DATE <= p_fecha_hasta)
        AND a.aso_mes_pago::DATE <= p_fecha_hasta
    ORDER BY a.aso_mes_pago, a.fecha_hora_pago;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rpt_estado_cuenta(INTEGER, DATE) TO PUBLIC;

-- ============================================
-- SP 12/12: sp_aseo_rpt_pagos
-- Descripcion: Reporte general de pagos
-- Parametros: Multiples filtros
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_rpt_pagos(DATE, DATE, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_rpt_pagos(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_tipo_aseo INTEGER DEFAULT NULL,
    p_empresa INTEGER DEFAULT NULL,
    p_forma_pago INTEGER DEFAULT NULL
)
RETURNS TABLE (
    num_contrato INTEGER,
    contribuyente VARCHAR,
    nombre_empresa VARCHAR,
    fecha_pago TIMESTAMP,
    periodo VARCHAR,
    concepto VARCHAR,
    forma_pago INTEGER,
    forma_pago_desc VARCHAR,
    importe NUMERIC(12,2),
    folio_rcbo VARCHAR,
    usuario VARCHAR,
    recaudadora VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.num_contrato,
        c.contribuyente,
        e.nom_emp as nombre_empresa,
        a.fecha_hora_pago as fecha_pago,
        TO_CHAR(a.aso_mes_pago, 'YYYY-MM') as periodo,
        co.descripcion as concepto,
        a.forma_pago,
        CASE a.forma_pago
            WHEN 1 THEN 'Efectivo'
            WHEN 2 THEN 'Cheque'
            WHEN 3 THEN 'Transferencia'
            WHEN 4 THEN 'Tarjeta'
            ELSE 'Sin Especificar'
        END as forma_pago_desc,
        a.importe,
        a.folio_rcbo,
        a.usuario,
        r.descripcion as recaudadora
    FROM ta_16_adeudos a
    INNER JOIN ta_16_contratos c ON a.control_contrato = c.control_contrato
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_emp
    LEFT JOIN ta_16_cves_operacion co ON a.ctrol_operacion = co.ctrol_operacion
    LEFT JOIN ta_16_recaudadoras r ON a.id_rec = r.num_rec
    WHERE a.status_vigencia = 'P'
        AND a.fecha_hora_pago IS NOT NULL
        AND a.fecha_hora_pago::DATE >= p_fecha_desde
        AND a.fecha_hora_pago::DATE <= p_fecha_hasta
        AND (p_tipo_aseo IS NULL OR c.ctrol_aseo = p_tipo_aseo)
        AND (p_empresa IS NULL OR c.num_empresa = p_empresa)
        AND (p_forma_pago IS NULL OR a.forma_pago = p_forma_pago)
    ORDER BY a.fecha_hora_pago DESC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_rpt_pagos(DATE, DATE, INTEGER, INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
