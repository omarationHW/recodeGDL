-- =============================================
-- Aseo Contratado - EstGral2 Module
-- Stored Procedures for General Statistics Report
-- Database: aseo_contratado
-- Schema: public
-- =============================================

-- =============================================
-- Function: estgral2_sp_get_estadisticas
-- Description: Get general statistics for reports
-- =============================================
CREATE OR REPLACE FUNCTION public.estgral2_sp_get_estadisticas(
    p_tipo_reporte VARCHAR,
    p_fecha VARCHAR
)
RETURNS TABLE (
    linea INTEGER,
    concepto1 VARCHAR,
    cant_concepto1 INTEGER,
    importe_concepto1 NUMERIC(12,2),
    concepto2 VARCHAR,
    cant_concepto2 INTEGER,
    importe_concepto2 NUMERIC(12,2),
    concepto3 VARCHAR,
    cant_concepto3 INTEGER,
    importe_concepto3 NUMERIC(12,2)
) AS $$
DECLARE
    v_ejercicio SMALLINT;
    v_mes SMALLINT;
BEGIN
    -- Parse fecha (formato: YYYY-MM)
    v_ejercicio := SPLIT_PART(p_fecha, '-', 1)::SMALLINT;
    v_mes := SPLIT_PART(p_fecha, '-', 2)::SMALLINT;

    IF p_tipo_reporte = 'V' THEN
        -- Vigencias
        RETURN QUERY
        SELECT
            1 as linea,
            'CONTRATOS VIGENTES'::VARCHAR as concepto1,
            COUNT(CASE WHEN c.status_vigencia = 'V' THEN 1 END)::INTEGER as cant_concepto1,
            COALESCE(SUM(CASE WHEN c.status_vigencia = 'V' THEN 0 END), 0)::NUMERIC(12,2) as importe_concepto1,
            'CONTRATOS NUEVOS'::VARCHAR as concepto2,
            COUNT(CASE WHEN c.status_vigencia = 'N' THEN 1 END)::INTEGER as cant_concepto2,
            COALESCE(SUM(CASE WHEN c.status_vigencia = 'N' THEN 0 END), 0)::NUMERIC(12,2) as importe_concepto2,
            'CONTRATOS CANCELADOS'::VARCHAR as concepto3,
            COUNT(CASE WHEN c.status_vigencia = 'C' THEN 1 END)::INTEGER as cant_concepto3,
            COALESCE(SUM(CASE WHEN c.status_vigencia = 'C' THEN 0 END), 0)::NUMERIC(12,2) as importe_concepto3
        FROM ta_16_contratos c
        WHERE c.fecha_hora_alta <= (v_ejercicio || '-' || LPAD(v_mes::TEXT, 2, '0') || '-01')::DATE;

    ELSE
        -- Obligaciones/Adeudos
        RETURN QUERY
        SELECT
            1 as linea,
            'CONTRATOS ACTIVOS'::VARCHAR as concepto1,
            COUNT(*)::INTEGER as cant_concepto1,
            COALESCE(SUM(0), 0)::NUMERIC(12,2) as importe_concepto1,
            'TIPO ASEO - CENTRO'::VARCHAR as concepto2,
            COUNT(CASE WHEN c.ctrol_aseo = 9 THEN 1 END)::INTEGER as cant_concepto2,
            COALESCE(SUM(CASE WHEN c.ctrol_aseo = 9 THEN 0 END), 0)::NUMERIC(12,2) as importe_concepto2,
            'TIPO ASEO - ORDINARIO'::VARCHAR as concepto3,
            COUNT(CASE WHEN c.ctrol_aseo = 8 THEN 1 END)::INTEGER as cant_concepto3,
            COALESCE(SUM(CASE WHEN c.ctrol_aseo = 8 THEN 0 END), 0)::NUMERIC(12,2) as importe_concepto3
        FROM ta_16_contratos c
        WHERE EXTRACT(YEAR FROM c.aso_mes_oblig) = v_ejercicio
          AND EXTRACT(MONTH FROM c.aso_mes_oblig) = v_mes
          AND c.status_vigencia IN ('V', 'N');
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: estgral2_sp_resumen_cifras
-- Description: Get summary of contracts and amounts
-- =============================================
CREATE OR REPLACE FUNCTION public.estgral2_sp_resumen_cifras(
    p_ejercicio SMALLINT,
    p_mes SMALLINT
)
RETURNS TABLE (
    total_contratos INTEGER,
    total_empresas INTEGER,
    total_zona_centro INTEGER,
    total_ordinarios INTEGER,
    total_hospitalarios INTEGER,
    promedio_recoleccion NUMERIC(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total_contratos,
        COUNT(DISTINCT c.num_empresa)::INTEGER as total_empresas,
        COUNT(CASE WHEN c.ctrol_aseo = 9 THEN 1 END)::INTEGER as total_zona_centro,
        COUNT(CASE WHEN c.ctrol_aseo = 8 THEN 1 END)::INTEGER as total_ordinarios,
        COUNT(CASE WHEN c.ctrol_aseo = 4 THEN 1 END)::INTEGER as total_hospitalarios,
        AVG(c.cantidad_recolec)::NUMERIC(10,2) as promedio_recoleccion
    FROM ta_16_contratos c
    WHERE EXTRACT(YEAR FROM c.aso_mes_oblig) = p_ejercicio
      AND EXTRACT(MONTH FROM c.aso_mes_oblig) = p_mes
      AND c.status_vigencia IN ('V', 'N');
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.estgral2_sp_get_estadisticas(VARCHAR, VARCHAR) IS 'Get general statistics for reports - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.estgral2_sp_resumen_cifras(SMALLINT, SMALLINT) IS 'Get summary of contracts and amounts - RefactorX Aseo Contratado';
