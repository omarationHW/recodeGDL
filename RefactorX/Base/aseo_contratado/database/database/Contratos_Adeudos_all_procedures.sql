-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Adeudos
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 1
-- ============================================
-- Descripción: Reporte de contratos con adeudos pendientes
-- Filtros según Delphi original:
--   parTipo: C=Zona Centro, H=Hospitalario, O=Ordinario, T=Todos
--   parVigencia: V=Vigente, N=Conveniado, C=Cancelado, S=Suspendido, T=Todos
--   parReporte: V=Periodos Vencidos, T=Otro Periodo
--   pref: Periodo en formato YYYY-MM
-- ============================================

-- SP 1/1: sp16_contratos_adeudo
-- Tipo: Report
-- Descripción: Obtiene la relación de contratos con adeudos pendientes
-- ============================================
DROP FUNCTION IF EXISTS public.sp16_contratos_adeudo(VARCHAR, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp16_contratos_adeudo(
    p_tipo VARCHAR,        -- Tipo de aseo: C, H, O, T (todos)
    p_vigencia VARCHAR,    -- Status: V=Vigente, N=Conveniado, C=Cancelado, S=Suspendido, T=Todos
    p_reporte VARCHAR,     -- V=Vencidos, T=Otro periodo
    p_periodo VARCHAR      -- YYYY-MM
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    calle VARCHAR,
    numext VARCHAR,
    numint VARCHAR,
    colonia VARCHAR,
    sector VARCHAR,
    status_contrato VARCHAR,
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    tipo_aseo_descripcion VARCHAR,
    cve_recoleccion VARCHAR,
    unidad_recoleccion VARCHAR,
    cantidad_recoleccion INTEGER,
    inicio_oblig VARCHAR,
    fin_oblig VARCHAR,
    adeudos_scr NUMERIC,
    adeudos_pag NUMERIC,
    primer_adeudo VARCHAR,
    adeudos NUMERIC,
    recargos NUMERIC,
    req_multa NUMERIC,
    req_gastos NUMERIC,
    documentos VARCHAR,
    licencias VARCHAR
) AS $$
DECLARE
    v_tipo_filter VARCHAR;
    v_vigencia_filter VARCHAR;
BEGIN
    -- Construir filtro de tipo
    IF p_tipo = 'T' OR p_tipo IS NULL THEN
        v_tipo_filter := '%';
    ELSE
        v_tipo_filter := p_tipo;
    END IF;

    -- Construir filtro de vigencia
    IF p_vigencia = 'T' OR p_vigencia IS NULL THEN
        v_vigencia_filter := '%';
    ELSE
        v_vigencia_filter := p_vigencia;
    END IF;

    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        COALESCE(c.calle, '')::VARCHAR as calle,
        COALESCE(c.num_ext, '')::VARCHAR as numext,
        COALESCE(c.num_int, '')::VARCHAR as numint,
        COALESCE(c.colonia, '')::VARCHAR as colonia,
        COALESCE(c.sector, '')::VARCHAR as sector,
        c.status_contrato::VARCHAR,
        COALESCE(c.num_empresa, 0)::INTEGER as num_empresa,
        COALESCE(e.nombre_empresa, 'SIN EMPRESA')::VARCHAR as nombre_empresa,
        COALESCE(ta.descripcion, '')::VARCHAR as tipo_aseo_descripcion,
        ''::VARCHAR as cve_recoleccion,
        ''::VARCHAR as unidad_recoleccion,
        0::INTEGER as cantidad_recoleccion,
        TO_CHAR(c.aso_mes_oblig, 'YYYY-MM')::VARCHAR as inicio_oblig,
        ''::VARCHAR as fin_oblig,
        COALESCE(SUM(CASE WHEN p.status_vigencia = 'V' THEN p.importe ELSE 0 END), 0)::NUMERIC as adeudos_scr,
        COALESCE(SUM(CASE WHEN p.status_vigencia = 'P' THEN p.importe ELSE 0 END), 0)::NUMERIC as adeudos_pag,
        MIN(TO_CHAR(p.aso_mes_pago, 'YYYY-MM'))::VARCHAR as primer_adeudo,
        COALESCE(SUM(CASE WHEN p.status_vigencia = 'V' THEN p.importe ELSE 0 END), 0)::NUMERIC as adeudos,
        0::NUMERIC as recargos,
        0::NUMERIC as req_multa,
        0::NUMERIC as req_gastos,
        ''::VARCHAR as documentos,
        ''::VARCHAR as licencias
    FROM ta_16_contratos c
    LEFT JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa
    LEFT JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    LEFT JOIN ta_16_pagos p ON p.control_contrato = c.control_contrato
        AND (
            (p_reporte = 'V' AND p.aso_mes_pago < CURRENT_DATE)
            OR
            (p_reporte = 'T' AND TO_CHAR(p.aso_mes_pago, 'YYYY-MM') = p_periodo)
        )
    WHERE (ta.tipo_aseo LIKE v_tipo_filter OR p_tipo = 'T')
      AND (c.status_contrato LIKE v_vigencia_filter OR p_vigencia = 'T')
    GROUP BY c.control_contrato, c.num_contrato, c.calle, c.num_ext, c.num_int,
             c.colonia, c.sector, c.status_contrato, c.num_empresa, e.nombre_empresa,
             ta.descripcion, c.aso_mes_oblig
    HAVING SUM(CASE WHEN p.status_vigencia = 'V' THEN p.importe ELSE 0 END) > 0
    ORDER BY c.num_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_contratos_adeudo(VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
