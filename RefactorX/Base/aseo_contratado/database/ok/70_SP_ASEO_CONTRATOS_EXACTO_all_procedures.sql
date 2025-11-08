-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS (EXACTO del archivo original)
-- Archivo: 70_SP_ASEO_CONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp16_contratos
-- Tipo: Report
-- Descripción: Obtiene la relación de contratos filtrando por tipo de aseo y vigencia.
-- --------------------------------------------

-- PostgreSQL version of sp16_contratos
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
        c.control_contrato,
        c.num_contrato,
        c.calle,
        c.numext,
        c.numint,
        c.colonia,
        c.sector,
        c.cp,
        c.rfc,
        c.municipio,
        c.estado,
        c.curp,
        c.status_contrato,
        c.num_empresa,
        e.nombre_empresa,
        e.representante_empresa,
        t.tipo_aseo,
        t.descripcion AS tipo_aseo_descripcion,
        u.cve_recoleccion,
        u.descripcion AS unidad_recoleccion,
        c.cantidad_recoleccion,
        to_char(c.inicio_oblig, 'YYYY-MM') AS inicio_oblig,
        to_char(c.fin_oblig, 'YYYY-MM') AS fin_oblig
    FROM contratos c
    JOIN empresas e ON c.num_empresa = e.num_empresa
    JOIN tipo_aseo t ON c.tipo_aseo = t.tipo_aseo
    JOIN unidades_recoleccion u ON c.cve_recoleccion = u.cve_recoleccion
    WHERE (parTipo = 'T' OR t.tipo_aseo = parTipo)
      AND (parVigencia = 'T' OR c.status_contrato = parVigencia)
    ORDER BY c.control_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS (EXACTO del archivo original)
-- Archivo: 70_SP_ASEO_CONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

