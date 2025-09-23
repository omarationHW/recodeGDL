-- Stored Procedure: sp_ctrol_imp_cat_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de claves de operación ordenado según parámetro: 1-Control, 2-Clave, 3-Descripción.
-- Generado para formulario: Ctrol_Imp_Cat
-- Fecha: 2025-08-27 14:32:13

CREATE OR REPLACE FUNCTION sp_ctrol_imp_cat_report(p_order integer)
RETURNS TABLE(ctrol_operacion integer, cve_operacion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY %s',
    CASE p_order
      WHEN 1 THEN 'ctrol_operacion'
      WHEN 2 THEN 'cve_operacion'
      WHEN 3 THEN 'descripcion'
      ELSE 'ctrol_operacion'
    END
  );
END;
$$;