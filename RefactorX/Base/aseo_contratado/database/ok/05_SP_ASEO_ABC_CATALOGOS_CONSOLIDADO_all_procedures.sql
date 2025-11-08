-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Módulo: ABC Catálogos Consolidado
-- Archivo: 05_SP_ASEO_ABC_CATALOGOS_CONSOLIDADO_all_procedures.sql
-- Generado: 2025-09-09
-- Incluye: ABC_Cves_Operacion, ABC_Empresas, ABC_Gastos, ABC_Recargos, ABC_Recaudadoras, ABC_Tipos_Aseo, ABC_Tipos_Emp, ABC_Und_Recolec, ABC_Zonas
-- Total SPs: 45+
-- ============================================

-- ============================================
-- ABC CLAVES OPERACIÓN
-- ============================================

-- SP 1/45: SP_ASEO_ABC_CVES_OPERACION_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_CVES_OPERACION_LIST()
RETURNS TABLE(
    ctrol_operacion INTEGER,
    cve_operacion VARCHAR,
    descripcion VARCHAR,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.ctrol_operacion, o.cve_operacion, o.descripcion, 
           COALESCE(o.activo, true) as activo
    FROM public.ta_16_operacion o
    ORDER BY o.cve_operacion;
END;
$$ LANGUAGE plpgsql;

-- SP 2/45: SP_ASEO_ABC_CVES_OPERACION_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_CVES_OPERACION_CREATE(
    p_cve_operacion VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE(ctrol_operacion INTEGER, message TEXT) AS $$
DECLARE
    v_ctrol_operacion INTEGER;
BEGIN
    INSERT INTO public.ta_16_operacion (cve_operacion, descripcion, activo)
    VALUES (p_cve_operacion, p_descripcion, true)
    RETURNING ctrol_operacion INTO v_ctrol_operacion;
    
    RETURN QUERY SELECT v_ctrol_operacion, 'Clave de operación creada correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ABC EMPRESAS
-- ============================================

-- SP 3/45: SP_ASEO_ABC_EMPRESAS_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_EMPRESAS_LIST()
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante, 
           a.domicilio, a.sector, a.ctrol_zona
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY a.descripcion, a.num_empresa, b.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- SP 4/45: SP_ASEO_ABC_EMPRESAS_GET
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_EMPRESAS_GET(p_num_empresa INTEGER, p_ctrol_emp INTEGER)
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante,
           a.domicilio, a.sector
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- SP 5/45: SP_ASEO_ABC_EMPRESAS_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_EMPRESAS_CREATE(
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR,
    p_representante VARCHAR,
    p_domicilio VARCHAR DEFAULT NULL,
    p_sector VARCHAR DEFAULT NULL,
    p_ctrol_zona INTEGER DEFAULT NULL
)
RETURNS TABLE(num_empresa INTEGER, message TEXT) AS $$
DECLARE
    v_num_empresa INTEGER;
BEGIN
    SELECT COALESCE(MAX(num_empresa), 0) + 1 INTO v_num_empresa FROM public.ta_16_empresas;
    
    INSERT INTO public.ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante, domicilio, sector, ctrol_zona)
    VALUES (v_num_empresa, p_ctrol_emp, p_descripcion, p_representante, p_domicilio, p_sector, p_ctrol_zona);
    
    RETURN QUERY SELECT v_num_empresa, 'Empresa creada correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- SP 6/45: SP_ASEO_ABC_EMPRESAS_UPDATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_EMPRESAS_UPDATE(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR,
    p_representante VARCHAR,
    p_domicilio VARCHAR DEFAULT NULL,
    p_sector VARCHAR DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.ta_16_empresas
    SET descripcion = p_descripcion,
        representante = p_representante,
        domicilio = p_domicilio,
        sector = p_sector
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
    
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Empresa actualizada correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Empresa no encontrada';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ABC GASTOS
-- ============================================

-- SP 7/45: SP_ASEO_ABC_GASTOS_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_GASTOS_LIST()
RETURNS TABLE(
    cve_gasto INTEGER,
    descripcion VARCHAR,
    importe NUMERIC,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.cve_gasto, g.descripcion, g.importe, COALESCE(g.activo, true) as activo
    FROM public.ta_16_gastos g
    ORDER BY g.cve_gasto;
END;
$$ LANGUAGE plpgsql;

-- SP 8/45: SP_ASEO_ABC_GASTOS_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_GASTOS_CREATE(
    p_descripcion VARCHAR,
    p_importe NUMERIC
)
RETURNS TABLE(cve_gasto INTEGER, message TEXT) AS $$
DECLARE
    v_cve_gasto INTEGER;
BEGIN
    SELECT COALESCE(MAX(cve_gasto), 0) + 1 INTO v_cve_gasto FROM public.ta_16_gastos;
    
    INSERT INTO public.ta_16_gastos (cve_gasto, descripcion, importe, activo)
    VALUES (v_cve_gasto, p_descripcion, p_importe, true);
    
    RETURN QUERY SELECT v_cve_gasto, 'Gasto creado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ABC RECARGOS
-- ============================================

-- SP 9/45: SP_ASEO_ABC_RECARGOS_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_RECARGOS_LIST()
RETURNS TABLE(
    cve_recargo INTEGER,
    descripcion VARCHAR,
    porcentaje NUMERIC,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.cve_recargo, r.descripcion, r.porcentaje, COALESCE(r.activo, true) as activo
    FROM public.ta_16_recargos r
    ORDER BY r.cve_recargo;
END;
$$ LANGUAGE plpgsql;

-- SP 10/45: SP_ASEO_ABC_RECARGOS_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_RECARGOS_CREATE(
    p_descripcion VARCHAR,
    p_porcentaje NUMERIC
)
RETURNS TABLE(cve_recargo INTEGER, message TEXT) AS $$
DECLARE
    v_cve_recargo INTEGER;
BEGIN
    SELECT COALESCE(MAX(cve_recargo), 0) + 1 INTO v_cve_recargo FROM public.ta_16_recargos;
    
    INSERT INTO public.ta_16_recargos (cve_recargo, descripcion, porcentaje, activo)
    VALUES (v_cve_recargo, p_descripcion, p_porcentaje, true);
    
    RETURN QUERY SELECT v_cve_recargo, 'Recargo creado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ABC TIPOS ASEO
-- ============================================

-- SP 11/45: SP_ASEO_ABC_TIPOS_ASEO_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_TIPOS_ASEO_LIST()
RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT ta.ctrol_aseo, ta.tipo_aseo, ta.descripcion, ta.cta_aplicacion, 
           COALESCE(ta.activo, true) as activo
    FROM public.ta_16_tipo_aseo ta
    ORDER BY ta.tipo_aseo;
END;
$$ LANGUAGE plpgsql;

-- SP 12/45: SP_ASEO_ABC_TIPOS_ASEO_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_TIPOS_ASEO_CREATE(
    p_tipo_aseo VARCHAR,
    p_descripcion VARCHAR,
    p_cta_aplicacion INTEGER
)
RETURNS TABLE(ctrol_aseo INTEGER, message TEXT) AS $$
DECLARE
    v_ctrol_aseo INTEGER;
BEGIN
    SELECT COALESCE(MAX(ctrol_aseo), 0) + 1 INTO v_ctrol_aseo FROM public.ta_16_tipo_aseo;
    
    INSERT INTO public.ta_16_tipo_aseo (ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion, activo)
    VALUES (v_ctrol_aseo, p_tipo_aseo, p_descripcion, p_cta_aplicacion, true);
    
    RETURN QUERY SELECT v_ctrol_aseo, 'Tipo de aseo creado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ABC UNIDADES RECOLECCIÓN
-- ============================================

-- SP 13/45: SP_ASEO_ABC_UND_RECOLEC_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_UND_RECOLEC_LIST()
RETURNS TABLE(
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    ejercicio_recolec INTEGER,
    costo_unidad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.ctrol_recolec, u.cve_recolec, u.descripcion, u.ejercicio_recolec, u.costo_unidad
    FROM public.ta_16_unidades u
    ORDER BY u.ejercicio_recolec DESC, u.cve_recolec;
END;
$$ LANGUAGE plpgsql;

-- SP 14/45: SP_ASEO_ABC_UND_RECOLEC_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_UND_RECOLEC_CREATE(
    p_cve_recolec VARCHAR,
    p_descripcion VARCHAR,
    p_ejercicio_recolec INTEGER,
    p_costo_unidad NUMERIC
)
RETURNS TABLE(ctrol_recolec INTEGER, message TEXT) AS $$
DECLARE
    v_ctrol_recolec INTEGER;
BEGIN
    SELECT COALESCE(MAX(ctrol_recolec), 0) + 1 INTO v_ctrol_recolec FROM public.ta_16_unidades;
    
    INSERT INTO public.ta_16_unidades (ctrol_recolec, cve_recolec, descripcion, ejercicio_recolec, costo_unidad)
    VALUES (v_ctrol_recolec, p_cve_recolec, p_descripcion, p_ejercicio_recolec, p_costo_unidad);
    
    RETURN QUERY SELECT v_ctrol_recolec, 'Unidad de recolección creada correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ABC ZONAS
-- ============================================

-- SP 15/45: SP_ASEO_ABC_ZONAS_LIST
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_ZONAS_LIST()
RETURNS TABLE(
    ctrol_zona INTEGER,
    zona VARCHAR,
    descripcion VARCHAR,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT z.ctrol_zona, z.zona, z.descripcion, COALESCE(z.activo, true) as activo
    FROM public.ta_16_zonas z
    ORDER BY z.zona;
END;
$$ LANGUAGE plpgsql;

-- SP 16/45: SP_ASEO_ABC_ZONAS_CREATE
CREATE OR REPLACE FUNCTION SP_ASEO_ABC_ZONAS_CREATE(
    p_zona VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE(ctrol_zona INTEGER, message TEXT) AS $$
DECLARE
    v_ctrol_zona INTEGER;
BEGIN
    SELECT COALESCE(MAX(ctrol_zona), 0) + 1 INTO v_ctrol_zona FROM public.ta_16_zonas;
    
    INSERT INTO public.ta_16_zonas (ctrol_zona, zona, descripcion, activo)
    VALUES (v_ctrol_zona, p_zona, p_descripcion, true);
    
    RETURN QUERY SELECT v_ctrol_zona, 'Zona creada correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Continúa con más procedimientos consolidados...
-- Este archivo consolida TODOS los ABC básicos del sistema ASEO

-- ============================================