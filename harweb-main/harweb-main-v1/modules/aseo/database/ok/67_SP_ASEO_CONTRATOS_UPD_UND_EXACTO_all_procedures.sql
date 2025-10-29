-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_UND (EXACTO del archivo original)
-- Archivo: 67_SP_ASEO_CONTRATOS_UPD_UND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: buscar_contrato_upd_und
-- Tipo: CRUD
-- Descripción: Devuelve los datos completos de un contrato vigente por número y tipo de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_contrato_upd_und(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion_2 VARCHAR,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    descripcion_3 VARCHAR,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion_4 VARCHAR,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion_1 VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato, c.num_contrato, c.ctrol_aseo, d.tipo_aseo, d.descripcion,
        c.ctrol_recolec, e.cve_recolec, e.descripcion, c.cantidad_recolec,
        c.domicilio, c.sector, c.ctrol_zona, f.zona, f.sub_zona, f.descripcion,
        c.id_rec, g.recaudadora, c.fecha_hora_alta, c.status_vigencia, c.aso_mes_oblig, c.cve, c.usuario, c.fecha_hora_baja,
        a.num_empresa, a.ctrol_emp, a.descripcion, a.representante
    FROM public.ta_16_contratos c
    JOIN public.ta_16_empresas a ON a.num_empresa = c.num_empresa AND a.ctrol_emp = c.ctrol_emp
    JOIN public.ta_16_tipos_emp b ON a.ctrol_emp = b.ctrol_emp
    JOIN public.ta_16_tipo_aseo d ON c.ctrol_aseo = d.ctrol_aseo
    JOIN public.ta_16_unidades e ON c.ctrol_recolec = e.ctrol_recolec
    JOIN public.ta_16_zonas f ON c.ctrol_zona = f.ctrol_zona
    JOIN public.ta_12_recaudadoras g ON c.id_rec = g.id_rec
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND c.status_vigencia = 'V'
    ORDER BY c.num_contrato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_UND (EXACTO del archivo original)
-- Archivo: 67_SP_ASEO_CONTRATOS_UPD_UND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: catalogo_unidades
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de unidades de recolección para un ejercicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_unidades(p_ejercicio INTEGER)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad
    FROM public.ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ctrol_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_UND (EXACTO del archivo original)
-- Archivo: 67_SP_ASEO_CONTRATOS_UPD_UND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

