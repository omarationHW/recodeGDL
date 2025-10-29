-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_PADRONCONTRATOS (EXACTO del archivo original)
-- Archivo: 94_SP_ASEO_REP_PADRONCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp16_contratos
-- Tipo: Report
-- Descripción: Obtiene el padrón de contratos filtrado por tipo y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_contratos(parTipo TEXT, parVigencia TEXT)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    calle TEXT,
    numext TEXT,
    numint TEXT,
    colonia TEXT,
    sector TEXT,
    cp TEXT,
    rfc TEXT,
    municipio TEXT,
    estado TEXT,
    curp TEXT,
    status_contrato TEXT,
    num_empresa INTEGER,
    nombre_empresa TEXT,
    representante_empresa TEXT,
    tipo_aseo TEXT,
    tipo_aseo_descripcion TEXT,
    cve_recoleccion TEXT,
    unidad_recoleccion TEXT,
    cantidad_recoleccion INTEGER,
    inicio_oblig TEXT,
    fin_oblig TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato, c.num_contrato, c.calle, c.numext, c.numint, c.colonia, c.sector, c.cp, c.rfc, c.municipio, c.estado, c.curp, c.status_contrato,
        c.num_empresa, e.descripcion AS nombre_empresa, e.representante AS representante_empresa,
        c.tipo_aseo, ta.descripcion AS tipo_aseo_descripcion, c.cve_recoleccion, u.descripcion AS unidad_recoleccion, c.cantidad_recoleccion,
        to_char(c.aso_mes_oblig, 'YYYY-MM') AS inicio_oblig,
        to_char(c.fecha_hora_baja, 'YYYY-MM') AS fin_oblig
    FROM public.ta_16_contratos c
    JOIN public.ta_16_empresas e ON e.num_empresa = c.num_empresa
    JOIN public.ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    JOIN public.ta_16_unidades u ON u.ctrol_recolec = c.ctrol_recolec
    WHERE (parTipo = 'T' OR c.tipo_aseo = parTipo)
      AND (parVigencia = 'T' OR c.status_vigencia = parVigencia)
    ORDER BY c.control_contrato, c.num_contrato, c.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_PADRONCONTRATOS (EXACTO del archivo original)
-- Archivo: 94_SP_ASEO_REP_PADRONCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: ta_16_dia_limite
-- Tipo: Catalog
-- Descripción: Tabla de días límite por mes para vencimiento de pagos.
-- --------------------------------------------

-- Tabla, no SP. Ejemplo de consulta:
-- SELECT * FROM public.ta_16_dia_limite WHERE mes = :mes;

-- ============================================

