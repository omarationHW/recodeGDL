-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Empresas_Contratos
-- Generado: 2025-08-27 14:37:53
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp16_empresa_contratos
-- Tipo: Report
-- Descripción: Obtiene la relación de empresas y contratos por empresa, con filtros por opción, descripción, tipo de aseo y vigencia.
-- --------------------------------------------

-- PostgreSQL version of sp16_empresa_contratos
CREATE OR REPLACE FUNCTION sp16_empresa_contratos(
    parOpc VARCHAR,
    parDescrip VARCHAR,
    parTipo VARCHAR,
    parVigencia VARCHAR
)
RETURNS TABLE (
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    representante_empresa VARCHAR,
    tipo_empresa VARCHAR,
    tipo_descripcion VARCHAR,
    control_contrato INTEGER,
    num_contrato INTEGER,
    calle VARCHAR,
    numext VARCHAR,
    numint VARCHAR,
    colonia VARCHAR,
    sector VARCHAR,
    cp VARCHAR,
    rfc VARCHAR,
    municipio VARCHAR,
    estado VARCHAR,
    curp VARCHAR,
    status_contrato VARCHAR,
    tipo_aseo VARCHAR,
    tipo_aseo_descripcion VARCHAR,
    cve_recoleccion VARCHAR,
    unidad_recoleccion VARCHAR,
    cantidad_recoleccion INTEGER,
    inicio_oblig VARCHAR,
    fin_oblig VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_empresa,
        e.descripcion AS nombre_empresa,
        e.representante AS representante_empresa,
        te.tipo_empresa,
        te.descripcion AS tipo_descripcion,
        c.control_contrato,
        c.num_contrato,
        c.domicilio AS calle,
        c.numext,
        c.numint,
        c.colonia,
        c.sector,
        c.cp,
        c.rfc,
        c.municipio,
        c.estado,
        c.curp,
        c.status_vigencia AS status_contrato,
        ta.tipo_aseo,
        ta.descripcion AS tipo_aseo_descripcion,
        u.cve_recolec AS cve_recoleccion,
        u.descripcion AS unidad_recoleccion,
        c.cantidad_recolec AS cantidad_recoleccion,
        to_char(c.aso_mes_oblig, 'YYYY-MM') AS inicio_oblig,
        to_char(c.fecha_hora_baja, 'YYYY-MM') AS fin_oblig
    FROM ta_16_empresas e
    INNER JOIN ta_16_tipos_emp te ON te.ctrol_emp = e.ctrol_emp
    LEFT JOIN ta_16_contratos c ON c.num_empresa = e.num_empresa AND c.ctrol_emp = e.ctrol_emp
    LEFT JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    LEFT JOIN ta_16_unidades u ON u.ctrol_recolec = c.ctrol_recolec
    WHERE
        (
            (parOpc = 'T') OR
            (parOpc = 'A' AND (
                e.descripcion ILIKE '%' || parDescrip || '%'
                OR e.representante ILIKE '%' || parDescrip || '%'
                OR CAST(e.num_empresa AS TEXT) = parDescrip
            ))
        )
        AND (parTipo = 'T' OR ta.tipo_aseo = parTipo)
        AND (parVigencia = 'T' OR c.status_vigencia = parVigencia)
    ORDER BY e.num_empresa, c.num_contrato;
END;
$$ LANGUAGE plpgsql;


-- ============================================

