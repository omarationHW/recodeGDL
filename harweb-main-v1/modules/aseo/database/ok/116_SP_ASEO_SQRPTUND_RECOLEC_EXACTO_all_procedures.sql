-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTUND_RECOLEC (EXACTO del archivo original)
-- Archivo: 116_SP_ASEO_SQRPTUND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_get_unidades_recolec
-- Tipo: Report
-- Descripción: Obtiene el catálogo de claves de recolección filtrado por ejercicio y ordenado por el campo especificado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_unidades_recolec(p_ejercicio integer, p_order_by text)
RETURNS TABLE (
    ctrol_recolec integer,
    cve_recolec varchar,
    descripcion varchar,
    costo_unidad numeric,
    ejercicio_recolec integer
) AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT ctrol_recolec, cve_recolec, descripcion, costo_unidad, ejercicio_recolec FROM public.ta_16_unidades WHERE ejercicio_recolec = $1 ORDER BY ';
    IF p_order_by = 'ctrol_recolec' THEN
        sql := sql || 'ctrol_recolec';
    ELSIF p_order_by = 'cve_recolec' THEN
        sql := sql || 'cve_recolec';
    ELSIF p_order_by = 'descripcion' THEN
        sql := sql || 'descripcion';
    ELSIF p_order_by = 'costo_unidad' THEN
        sql := sql || 'costo_unidad';
    ELSE
        sql := sql || 'ctrol_recolec';
    END IF;
    RETURN QUERY EXECUTE sql USING p_ejercicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

