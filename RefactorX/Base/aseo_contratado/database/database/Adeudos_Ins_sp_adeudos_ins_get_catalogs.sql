-- Stored Procedure: sp_adeudos_ins_get_catalogs
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipo de aseo, tipo de operación y meses.
-- Generado para formulario: Adeudos_Ins
-- Fecha: 2025-08-27 13:44:07

-- PostgreSQL stored procedure for getting catalogs
CREATE OR REPLACE FUNCTION sp_adeudos_ins_get_catalogs()
RETURNS TABLE(tipo_aseo jsonb, tipo_operacion jsonb, meses jsonb) AS $$
BEGIN
    RETURN QUERY SELECT
        (SELECT jsonb_agg(row_to_json(t)) FROM (SELECT ctrol_aseo, tipo_aseo, descripcion FROM cat_tipo_aseo ORDER BY ctrol_aseo) t),
        (SELECT jsonb_agg(row_to_json(t)) FROM (SELECT ctrol_operacion, cve_operacion, descripcion FROM cat_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion) t),
        '[{"value":"01","label":"Enero"},{"value":"02","label":"Febrero"},{"value":"03","label":"Marzo"},{"value":"04","label":"Abril"},{"value":"05","label":"Mayo"},{"value":"06","label":"Junio"},{"value":"07","label":"Julio"},{"value":"08","label":"Agosto"},{"value":"09","label":"Septiembre"},{"value":"10","label":"Octubre"},{"value":"11","label":"Noviembre"},{"value":"12","label":"Diciembre"}]'::jsonb;
END;
$$ LANGUAGE plpgsql;