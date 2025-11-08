-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Cons_Zonas
-- Generado: 2025-08-27 14:06:40
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_cons_zonas_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de zonas ordenado según el campo especificado.
-- --------------------------------------------

-- PostgreSQL stored procedure for listing zonas
CREATE OR REPLACE FUNCTION sp_cons_zonas_list(p_order text DEFAULT 'ctrol_zona')
RETURNS TABLE (
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion varchar
) AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY ' || quote_ident(p_order);
    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

