-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: LICENCIAS_RELACIONADAS (EXACTO del archivo original)
-- Archivo: 76_SP_ASEO_LICENCIAS_RELACIONADAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp16_licenciagiro_abc
-- Tipo: CRUD
-- Descripción: Alta, baja (desligar), o actualización de relación entre licencia y contrato
-- --------------------------------------------

-- PostgreSQL version of sp16_LicenciaGiro_ABC
CREATE OR REPLACE FUNCTION sp16_licenciagiro_abc(
    par_opc VARCHAR,
    par_licenciagiro INTEGER,
    par_control_contrato INTEGER,
    par_usuario INTEGER DEFAULT 0
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS $$
DECLARE
BEGIN
    IF par_opc = 'D' THEN
        DELETE FROM public.ta_16_rel_licgiro
        WHERE num_licencia = par_licenciagiro AND control_contrato = par_control_contrato;
        RETURN QUERY SELECT 0 AS status, 'Licencia desligada correctamente' AS leyenda;
    ELSIF par_opc = 'A' THEN
        INSERT INTO public.ta_16_rel_licgiro (num_licencia, control_contrato, vigencia, usuario)
        VALUES (par_licenciagiro, par_control_contrato, 'V', par_usuario)
        ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V', usuario = par_usuario;
        RETURN QUERY SELECT 0 AS status, 'Licencia ligada correctamente' AS leyenda;
    ELSE
        RETURN QUERY SELECT 1 AS status, 'Operación no soportada' AS leyenda;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: LICENCIAS_RELACIONADAS (EXACTO del archivo original)
-- Archivo: 76_SP_ASEO_LICENCIAS_RELACIONADAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp16_tipos_aseo
-- Tipo: Catalog
-- Descripción: Catálogo de tipos de aseo
-- --------------------------------------------

-- PostgreSQL version for catálogo de tipos de aseo
CREATE OR REPLACE FUNCTION sp16_tipos_aseo() RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM public.ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

