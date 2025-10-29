-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

-- SP 1/12: sp_cat_unidades_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_list(p_ejercicio INTEGER)
RETURNS TABLE(
    id SERIAL,
    ejercicio INTEGER,
    clave VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM public.ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

-- SP 3/12: sp_cat_unidades_update
-- Tipo: Catalog
-- Descripción: Actualiza una unidad de recolección existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_update(
    p_id INTEGER,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    UPDATE public.ta_16_unidades
    SET descripcion = p_descripcion, costo_unidad = p_costo_unidad, costo_exed = p_costo_exed
    WHERE id = p_id;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

-- SP 5/12: sp_cat_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_list()
RETURNS TABLE(id SERIAL, tipo_aseo VARCHAR, descripcion VARCHAR, cta_aplicacion INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, tipo_aseo, descripcion, cta_aplicacion FROM public.ta_16_tipo_aseo ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

-- SP 7/12: sp_cat_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_empresas_list()
RETURNS TABLE(id SERIAL, num_empresa INTEGER, ctrol_emp INTEGER, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, num_empresa, ctrol_emp, descripcion, representante FROM public.ta_16_empresas ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

-- SP 9/12: sp_cat_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un ejercicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_recargos_list(p_ejercicio INTEGER)
RETURNS TABLE(id SERIAL, aso_mes_recargo DATE, porc_recargo NUMERIC, porc_multa NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT id, aso_mes_recargo, porc_recargo, porc_multa FROM public.ta_16_recargos WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_ejercicio ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

-- SP 11/12: sp_cat_operaciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_operaciones_list()
RETURNS TABLE(id SERIAL, cve_operacion VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cve_operacion, descripcion FROM public.ta_16_operacion ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MENU (EXACTO del archivo original)
-- Archivo: 86_SP_ASEO_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 12 (EXACTO)
-- ============================================

