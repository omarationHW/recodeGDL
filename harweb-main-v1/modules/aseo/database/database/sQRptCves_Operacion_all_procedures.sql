-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptCves_Operacion
-- Generado: 2025-08-27 15:33:12
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_get_operaciones
-- Tipo: Report
-- Descripción: Obtiene el catálogo de claves de operación ordenado según la opción seleccionada (1=ctrol_operacion, 2=cve_operacion, 3=descripcion). Devuelve cada fila como JSON.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_operaciones(opcion integer)
RETURNS SETOF json AS $$
DECLARE
    sql TEXT;
    rec RECORD;
BEGIN
    IF opcion = 1 THEN
        sql := 'SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY ctrol_operacion';
    ELSIF opcion = 2 THEN
        sql := 'SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY cve_operacion';
    ELSIF opcion = 3 THEN
        sql := 'SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY descripcion';
    ELSE
        sql := 'SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY ctrol_operacion';
    END IF;

    FOR rec IN EXECUTE sql LOOP
        RETURN NEXT to_json(rec);
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- ============================================

