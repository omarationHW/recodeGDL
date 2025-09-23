-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Adeudos
-- Generado: 2025-08-27 14:11:20
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp16_contratos_adeudo
-- Tipo: Report
-- Descripción: Obtiene la relación de contratos con adeudos y datos relacionados, filtrando por tipo de aseo, vigencia, tipo de reporte y periodo pref.
-- --------------------------------------------

-- PostgreSQL version of sp16_contratos_adeudo
CREATE OR REPLACE FUNCTION sp16_contratos_adeudo(
    parTipo VARCHAR,
    parVigencia VARCHAR,
    parReporte VARCHAR,
    pref VARCHAR
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
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato,
        c.num_contrato,
        c.calle,
        c.numext,
        c.numint,
        c.colonia,
        c.sector,
        CASE c.status_vigencia
            WHEN 'V' THEN 'VIGENTE'
            WHEN 'N' THEN 'CONVENIADO'
            WHEN 'C' THEN 'CANCELADO'
            WHEN 'S' THEN 'SUSPENDIDO'
            ELSE c.status_vigencia
        END AS status_contrato,
        c.num_empresa,
        e.descripcion AS nombre_empresa,
        ta.descripcion AS tipo_aseo_descripcion,
        u.cve_recolec AS cve_recoleccion,
        u.descripcion AS unidad_recoleccion,
        c.cantidad_recolec AS cantidad_recoleccion,
        to_char(c.aso_mes_oblig, 'YYYY-MM') AS inicio_oblig,
        to_char(c.fecha_hora_baja, 'YYYY-MM') AS fin_oblig,
        0 AS adeudos_scr, -- Aquí deberías calcular los adeudos condonados/cancelados/prescritos
        0 AS adeudos_pag, -- Aquí deberías calcular los pagados
        '' AS primer_adeudo, -- Aquí deberías calcular el primer adeudo
        0 AS adeudos, -- Aquí deberías calcular los adeudos vigentes
        0 AS recargos, -- Aquí deberías calcular los recargos
        0 AS req_multa, -- Aquí deberías calcular la multa
        0 AS req_gastos, -- Aquí deberías calcular los gastos
        '' AS documentos, -- Aquí deberías concatenar los documentos
        '' AS licencias -- Aquí deberías concatenar las licencias
    FROM ta_16_contratos c
    INNER JOIN ta_16_empresas e ON c.num_empresa = e.num_empresa AND c.ctrol_emp = e.ctrol_emp
    INNER JOIN ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    INNER JOIN ta_16_unidades u ON c.ctrol_recolec = u.ctrol_recolec
    WHERE (parTipo = 'T' OR ta.tipo_aseo = parTipo)
      AND (parVigencia = 'T' OR c.status_vigencia = parVigencia)
      AND (
        parReporte = 'V' OR (
          to_char(c.aso_mes_oblig, 'YYYY-MM') <= pref
        )
      );
END;
$$ LANGUAGE plpgsql;


-- ============================================

