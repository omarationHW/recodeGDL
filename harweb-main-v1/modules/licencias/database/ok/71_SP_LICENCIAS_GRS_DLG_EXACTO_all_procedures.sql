-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: GRS_DLG (EXACTO del archivo original)
-- Archivo: 71_SP_LICENCIAS_GRS_DLG_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_grs_dlg_search
-- Tipo: Catalog
-- Descripción: Realiza una búsqueda parcial (o exacta) en una tabla y campo especificados, con opción de case-insensitive.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_grs_dlg_search(
    p_table text,
    p_field text,
    p_value text,
    p_case_insensitive boolean DEFAULT true,
    p_partial boolean DEFAULT true
)
RETURNS SETOF RECORD AS $$
DECLARE
    sql text;
    ref refcursor;
    q_value text;
BEGIN
    IF p_partial THEN
        q_value := '%' || p_value || '%';
    ELSE
        q_value := p_value;
    END IF;

    IF p_case_insensitive THEN
        sql := format('SELECT * FROM %I WHERE %I ILIKE $1', p_table, p_field);
    ELSE
        sql := format('SELECT * FROM %I WHERE %I LIKE $1', p_table, p_field);
    END IF;

    OPEN ref FOR EXECUTE sql USING q_value;
    RETURN QUERY FETCH ALL FROM ref;
    CLOSE ref;
END;
$$ LANGUAGE plpgsql;


-- ============================================

