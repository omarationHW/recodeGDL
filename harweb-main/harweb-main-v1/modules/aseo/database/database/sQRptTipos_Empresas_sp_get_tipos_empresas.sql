-- Stored Procedure: sp_get_tipos_empresas
-- Tipo: Report
-- Descripción: Obtiene el catálogo de tipos de empresas ordenado por el criterio solicitado (1=ctrol_emp, 2=tipo_empresa, 3=descripcion).
-- Generado para formulario: sQRptTipos_Empresas
-- Fecha: 2025-08-27 15:38:55

CREATE OR REPLACE FUNCTION sp_get_tipos_empresas(opcion integer)
RETURNS SETOF ta_16_tipos_emp AS $$
DECLARE
    order_clause text;
    sql_query text;
BEGIN
    IF opcion = 1 THEN
        order_clause := 'ctrol_emp';
    ELSIF opcion = 2 THEN
        order_clause := 'tipo_empresa';
    ELSIF opcion = 3 THEN
        order_clause := 'descripcion';
    ELSE
        order_clause := 'ctrol_emp';
    END IF;
    sql_query := 'SELECT * FROM ta_16_tipos_emp ORDER BY ' || order_clause;
    RETURN QUERY EXECUTE sql_query;
END;
$$ LANGUAGE plpgsql;