-- =============================================
-- Aseo Contratado - RelacionContratos Module
-- Stored Procedures for Contracts Relationship/Listing
-- Database: aseo_contratado
-- Schema: public
-- =============================================

-- =============================================
-- Function: relacioncontratos_sp_listar
-- Description: List contracts with relationships
-- =============================================
CREATE OR REPLACE FUNCTION public.relacioncontratos_sp_listar(
    p_tipo_aseo INTEGER DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL,
    p_ejercicio SMALLINT DEFAULT NULL
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    representante VARCHAR,
    tipo_aseo VARCHAR,
    descripcion_aseo VARCHAR,
    cve_recolec VARCHAR,
    descripcion_recolec VARCHAR,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    zona VARCHAR,
    recaudadora VARCHAR,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    fecha_alta TIMESTAMP,
    tiene_licencias INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.num_empresa,
        e.descripcion as nombre_empresa,
        e.representante,
        ta.tipo_aseo,
        ta.descripcion as descripcion_aseo,
        ur.cve_recolec,
        ur.descripcion as descripcion_recolec,
        c.cantidad_recolec,
        c.domicilio,
        c.sector,
        (z.zona::TEXT || '-' || z.sub_zona::TEXT || ' ' || z.descripcion)::VARCHAR as zona,
        r.recaudadora,
        c.status_vigencia,
        c.aso_mes_oblig,
        c.fecha_hora_alta,
        (SELECT COUNT(*)::INTEGER
         FROM ta_16_licencias_relacionadas lr
         WHERE lr.control_contrato = c.control_contrato)
    FROM ta_16_contratos c
    INNER JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp
    INNER JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    INNER JOIN ta_16_unidades ur ON ur.ctrol_recolec = c.ctrol_recolec
    INNER JOIN ta_16_zonas z ON z.ctrol_zona = c.ctrol_zona
    LEFT JOIN ta_12_recaudadoras r ON r.id_rec = c.id_rec
    WHERE (p_tipo_aseo IS NULL OR c.ctrol_aseo = p_tipo_aseo)
      AND (p_status IS NULL OR c.status_vigencia = p_status)
      AND (p_ejercicio IS NULL OR EXTRACT(YEAR FROM c.aso_mes_oblig) = p_ejercicio)
    ORDER BY c.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: relacioncontratos_sp_get_licencias
-- Description: Get related licenses for a contract
-- =============================================
CREATE OR REPLACE FUNCTION public.relacioncontratos_sp_get_licencias(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    num_licencia INTEGER,
    actividad VARCHAR,
    propietario VARCHAR,
    direccion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        lr.num_licencia,
        COALESCE(l.actividad, 'N/A')::VARCHAR as actividad,
        COALESCE(l.propietario, 'N/A')::VARCHAR as propietario,
        COALESCE(l.direccion, 'N/A')::VARCHAR as direccion
    FROM ta_16_licencias_relacionadas lr
    LEFT JOIN (
        SELECT 1 as num_licencia, 'Actividad ejemplo'::VARCHAR as actividad,
               'Propietario ejemplo'::VARCHAR as propietario, 'Direccion ejemplo'::VARCHAR as direccion
    ) l ON l.num_licencia = lr.num_licencia
    WHERE lr.control_contrato = p_control_contrato
    ORDER BY lr.num_licencia;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: relacioncontratos_sp_estadisticas
-- Description: Get statistics of contracts relationships
-- =============================================
CREATE OR REPLACE FUNCTION public.relacioncontratos_sp_estadisticas()
RETURNS TABLE (
    total_contratos INTEGER,
    contratos_con_licencias INTEGER,
    contratos_sin_licencias INTEGER,
    total_licencias INTEGER,
    promedio_licencias_por_contrato NUMERIC(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT c.control_contrato)::INTEGER as total_contratos,
        COUNT(DISTINCT CASE WHEN lr.num_licencia IS NOT NULL THEN c.control_contrato END)::INTEGER as contratos_con_licencias,
        COUNT(DISTINCT CASE WHEN lr.num_licencia IS NULL THEN c.control_contrato END)::INTEGER as contratos_sin_licencias,
        COUNT(lr.num_licencia)::INTEGER as total_licencias,
        CASE
            WHEN COUNT(DISTINCT c.control_contrato) > 0
            THEN (COUNT(lr.num_licencia)::NUMERIC / COUNT(DISTINCT c.control_contrato)::NUMERIC)
            ELSE 0
        END::NUMERIC(10,2) as promedio_licencias_por_contrato
    FROM ta_16_contratos c
    LEFT JOIN ta_16_licencias_relacionadas lr ON lr.control_contrato = c.control_contrato;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.relacioncontratos_sp_listar(INTEGER, VARCHAR, SMALLINT) IS 'List contracts with relationships - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.relacioncontratos_sp_get_licencias(INTEGER) IS 'Get related licenses for contract - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.relacioncontratos_sp_estadisticas() IS 'Get contracts relationships statistics - RefactorX Aseo Contratado';
